## Context

aura-cli currently supports two non-interactive subcommands (`--version`, `current`) parsed manually in `main.swift` before TUI initialization. The `current` command reads provider state without side effects. The new `switch` command needs to both read and write state (activate a provider), following the same pre-TUI pattern.

Provider activation already exists in `ProviderStore.activateProvider(_:)` (marks provider active, persists to JSON) and `ConfigManager.updateEnvVariables(_:)` (writes env vars to `~/.claude/settings.json`). The TUI's `AppViewModel.activateProvider(_:)` orchestrates both — the switch command needs the same orchestration without the TUI.

## Goals / Non-Goals

**Goals:**
- Enable switching providers from the command line in a single command
- Support deactivation (restore defaults) via `--off` flag
- Match by provider name (case-insensitive)
- Provide clear error messages for not-found or ambiguous matches

**Non-Goals:**
- Tab completion or fuzzy matching (future enhancement)
- Listing available providers (use `current` or the TUI for discovery)
- Switching by provider ID (names are more ergonomic for CLI use)

## Decisions

**1. Match providers by name, case-insensitive**

Rationale: Provider names are user-facing strings (e.g., "Zhipu AI"). Case-insensitive matching avoids frustration with capitalization. If multiple providers share a name (unlikely but possible), exit with an error listing matches rather than picking one silently.

Alternative considered: Match by UUID — rejected because UUIDs are not memorable and would require a separate `list` command to discover them.

**2. Run `ConfigImportService.syncOnStartup()` before switching**

Rationale: Unlike `current` (read-only), `switch` writes state. Running sync first ensures the provider list is reconciled with any external changes to `settings.json`, preventing stale state from causing incorrect activation. This matches the TUI's startup behavior.

Alternative considered: Skip sync like `current` does — rejected because writing stale state could overwrite manual edits.

**3. Reuse existing activation logic directly**

Rationale: `ProviderStore.activateProvider(_:)` + `ConfigManager.updateEnvVariables(_:)` already implement the full activation flow. The switch command calls these directly rather than going through `AppViewModel`, avoiding a dependency on the view layer.

**4. Argument parsing stays manual (no ArgumentParser dependency)**

Rationale: The project currently parses args manually. Adding swift-argument-parser for one subcommand is disproportionate. The `switch` command takes a single positional argument and one optional flag — simple enough for manual parsing.

## Risks / Trade-offs

- [Name collision] Two providers with the same name → Mitigation: error with "multiple providers match" message listing them
- [Sync side effects] Running syncOnStartup before switch could create/modify providers unexpectedly → Mitigation: this is the same behavior as launching the TUI; users expect it
- [No confirmation] Switching silently overwrites settings.json env vars → Mitigation: a backup is already created by ConfigManager; matches TUI behavior where activation is also instant
