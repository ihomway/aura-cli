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

**aura-cli** is a macOS terminal UI tool (requires macOS 14+) built with [SwiftTUI](https://github.com/rensbreur/SwiftTUI) that manages multiple Claude API providers by switching environment variables in `~/.claude/settings.json`.

**Pattern: MVVM with singleton services**

### Data flow

1. On launch, `ConfigImportService.syncOnStartup()` reconciles `~/.claude/settings.json` with the provider list at `~/.claude/aura-providers.json` (three-phase: check active provider → search all providers → create from config)
2. `ProviderStore` loads/persists providers; `ConfigManager` reads/writes env vars in settings.json
3. `AppViewModel` (ObservableObject) owns `currentScreen`, `providers`, `activeProviderID`, `statusMessage`, and `duplicateWarning`
4. Views read from ViewModel and call its action methods; ViewModel delegates to services and calls `reloadProviders()` to push updates back

### Navigation model

`AppScreen` enum drives all navigation: `.list` → `.selectTemplate` → `.addForm(ProviderTemplate)` or `.edit(Provider)` / `.deleteConfirm(Provider)`. `RootView` switches on this to render the correct view.

### Key behaviors

- **Activating a provider** writes its `envVariables` into `~/.claude/settings.json` (with backup at `.backup`); deactivating restores the backup
- **Token duplicate detection** (`TokenCheckResult`) distinguishes same-URL vs different-URL duplicates and surfaces a warning in the form views before committing
- **Icon inference** (`ProviderStore.inferIcon(from:)`) maps base URL domains to icon names; called before save in Add/Edit views
- **ProviderTemplate** defines the five built-in presets (Anthropic, Zhipu AI, z.ai, Moonshot AI, Other/Custom) with their default env var keys and model names
