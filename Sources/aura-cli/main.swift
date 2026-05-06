//
//  main.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation
import TauTUI

let version = "0.2.0"

// Handle --version and --help flags before launching TUI
let args = CommandLine.arguments

if args.contains("--version") || args.contains("-v") {
    print("aura-cli \(version)")
    exit(0)
}

if args.contains("--help") || args.contains("-h") {
    print("""
    aura-cli \(version)
    A TUI for managing Claude Code API providers.

    USAGE:
        aura-cli [COMMAND] [OPTIONS]

    COMMANDS:
        current          Print the active provider configuration as JSON
        switch <name>    Activate a provider by name
        switch --off     Deactivate all providers (restore default)

    OPTIONS:
        -h, --help       Print help information
        -v, --version    Print version

    CONTROLS (interactive TUI):
        ↑ / ↓           Navigate between items
        Enter           Activate / confirm / move to next field
        Tab             Move to next field (in forms)
        Esc             Go back / cancel

    CONFIGURATION:
        Providers are stored at ~/.claude/aura-providers.json
        Active provider is applied to ~/.claude/settings.json
    """)
    exit(0)
}

if args.dropFirst().first == "current" {
    struct DefaultOutput: Encodable { let name = "Default" }
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let output: Data
    if let provider = ProviderStore.shared.activeProvider {
        output = (try? encoder.encode(provider)) ?? Data()
    } else {
        output = (try? encoder.encode(DefaultOutput())) ?? Data()
    }
    print(String(decoding: output, as: UTF8.self))
    exit(0)
}

if args.dropFirst().first == "switch" {
    let switchArgs = Array(args.dropFirst(2))

    if switchArgs.contains("--off") {
        ConfigImportService.shared.syncOnStartup()
        let wasActive = ProviderStore.shared.activeProvider != nil
        ProviderStore.shared.deactivateAll()
        ConfigManager.shared.clearEnvVariables()
        if wasActive {
            print("Switched to default (all providers deactivated)")
        } else {
            print("Already on default (no active provider)")
        }
        exit(0)
    }

    guard !switchArgs.isEmpty else {
        fputs("Usage: aura-cli switch <name> | --off\n", stderr)
        exit(1)
    }

    let name = switchArgs.joined(separator: " ")

    ConfigImportService.shared.syncOnStartup()

    let matches = ProviderStore.shared.providers.filter {
        $0.name.lowercased() == name.lowercased()
    }

    if matches.isEmpty {
        fputs("Error: no provider found matching \"\(name)\"\n", stderr)
        exit(1)
    }

    if matches.count > 1 {
        fputs("Error: multiple providers match \"\(name)\":\n", stderr)
        for match in matches {
            fputs("  - \(match.name)\n", stderr)
        }
        exit(1)
    }

    let provider = matches[0]
    ProviderStore.shared.activateProvider(provider)
    ConfigManager.shared.updateEnvVariables(provider.envVariables)
    print("Switched to \"\(provider.name)\"")
    exit(0)
}

// Run startup sync before launching the TUI (nonisolated file I/O)
ConfigImportService.shared.syncOnStartup()

// Build the TUI on the main actor.
// MainActor.assumeIsolated is safe here: top-level main.swift always runs on the main thread.
MainActor.assumeIsolated {
    let terminal = ProcessTerminal()
    let tui = TUI(terminal: terminal)

    let viewModel = AppViewModel()
    let appComponent = AppComponent(viewModel: viewModel)

    // Wire callbacks — both called from main-thread callbacks, so assumeIsolated is safe.
    viewModel.onStateChange = {
        MainActor.assumeIsolated { tui.requestRender() }
    }
    appComponent.requestRender = {
        MainActor.assumeIsolated { tui.requestRender() }
    }
    appComponent.onQuit = {
        MainActor.assumeIsolated { tui.stop() }
        exit(0)
    }

    tui.addChild(appComponent)
    tui.setFocus(appComponent)

    do {
        try tui.start()
    } catch {
        fputs("aura-cli: failed to start TUI: \(error)\n", stderr)
        exit(1)
    }
}

RunLoop.main.run()
