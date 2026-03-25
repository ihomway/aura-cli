//
//  main.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation
import SwiftTUI

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
        Enter           Activate / confirm selection
        Tab             Move to next field

    CONFIGURATION:
        Providers are stored at ~/.claude/aura-providers.json
        Active provider is applied to ~/.claude/settings.json
    """)
    exit(0)
}

// Run startup sync before launching the TUI
ConfigImportService.shared.syncOnStartup()

// Create ViewModel outside the view tree (no @StateObject in SwiftTUI)
let viewModel = AppViewModel()

// Launch TUI
let app = Application(rootView: RootView(viewModel: viewModel))
app.start()
