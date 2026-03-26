# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build
swift build

# Build release
swift build -c release

# Run
swift run aura-cli

# Run with flags
swift run aura-cli --version
swift run aura-cli --help
```

No tests exist yet.

## Architecture

**aura-cli** is a macOS terminal UI tool (requires macOS 14+) built with [TauTUI](https://github.com/steipete/TauTUI) that manages multiple Claude API providers by switching environment variables in `~/.claude/settings.json`.

**Pattern: MVVM with singleton services**

### Data flow

1. On launch, `ConfigImportService.syncOnStartup()` reconciles `~/.claude/settings.json` with the provider list at `~/.claude/aura-providers.json` (three-phase: check active provider → search all providers → create from config)
2. `ProviderStore` loads/persists providers; `ConfigManager` reads/writes env vars in settings.json
3. `AppViewModel` owns `currentScreen`, `providers`, `activeProviderID`, `statusMessage`, and `duplicateWarning`; state changes trigger re-renders via `onStateChange: () -> Void`
4. `AppComponent` (TauTUI `Component`) reads from ViewModel and calls its action methods; renders all screens from a single `render(width:)` switch and handles all keyboard input via `handle(input:)`

### TUI layer

The entire UI lives in `Sources/aura-cli/Views/AppComponent.swift`. It implements TauTUI's `Component` protocol directly — no SwiftUI-style views. Key points:

- `render(width:) -> [String]` returns plain text lines; switching on `viewModel.currentScreen`
- `handle(input: TerminalInput)` receives keyboard events from TauTUI and delegates to per-screen handlers
- Local cursor/field state (`listIndex`, `formFieldIndex`, `formValues`, etc.) lives on `AppComponent`; business state lives on `AppViewModel`
- `requestRender: () -> Void` and `onQuit: () -> Void` callbacks are set by `main.swift` to call `tui.requestRender()` and `tui.stop()` + `exit(0)` respectively
- `MainActor.assumeIsolated` bridges the non-isolated top-level `main.swift` to TauTUI's `@MainActor`-isolated `TUI` and `ProcessTerminal` types

### Navigation model

`AppScreen` enum drives all navigation: `.list` → `.selectTemplate` → `.addForm(ProviderTemplate)` or `.edit(Provider)` / `.deleteConfirm(Provider)`. `AppComponent.render(width:)` switches on this to render the correct screen.

### Key behaviors

- **Activating a provider** writes its `envVariables` into `~/.claude/settings.json` (with backup at `.backup`); deactivating restores the backup
- **Token duplicate detection** (`TokenCheckResult`) distinguishes same-URL vs different-URL duplicates and surfaces a warning in the form screens before committing
- **Icon inference** (`ProviderStore.inferIcon(from:)`) maps base URL domains to icon names; called before save in Add/Edit screens
- **ProviderTemplate** defines the five built-in presets (Anthropic, Zhipu AI, z.ai, Moonshot AI, Other/Custom) with their default env var keys and model names
- **Terminal restore** — quitting via `q` calls `tui.stop()` before `exit(0)` to restore raw-mode terminal settings
