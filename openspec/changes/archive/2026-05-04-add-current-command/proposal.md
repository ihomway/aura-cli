## Why

Users have no way to query the active provider configuration from the command line without opening the TUI or manually inspecting `~/.claude/settings.json`. A `current` subcommand enables scripting, CI checks, and quick inspection of the active provider.

## What Changes

- Add a `current` subcommand to the `aura-cli` CLI entry point
- When an aura-managed provider is active, output its full provider JSON (name, icon, isActive, envVariables, id)
- When no aura provider is active (default Claude account), output `{"name": "Default"}`
- Output is machine-readable JSON printed to stdout

## Capabilities

### New Capabilities

- `current-command`: CLI subcommand `aura-cli current` that prints the active provider configuration as JSON

### Modified Capabilities

<!-- No existing spec-level requirements change -->

## Impact

- `Sources/aura-cli/main.swift` — add argument parsing to dispatch the `current` subcommand before launching the TUI
- `ProviderStore` / `ConfigManager` — read active provider without launching the full TUI stack
- No breaking changes; existing TUI behavior is unchanged
