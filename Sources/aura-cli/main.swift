//
//  main.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation
import TauTUI

let version = "0.1.0"

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
        aura-cli [OPTIONS]

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
