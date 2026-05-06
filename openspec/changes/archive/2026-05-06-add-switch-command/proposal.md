## Why

Users need a way to switch between provider configurations directly from the command line without launching the interactive TUI. This enables scripting, shell aliases, and faster workflows when the user already knows which provider they want to activate.

## What Changes

- Add a `switch` subcommand that activates a provider by name (e.g., `aura-cli switch "Zhipu AI"`)
- The command writes the provider's env variables to `~/.claude/settings.json` (same as TUI activation) and exits
- Supports a `--off` flag to deactivate all providers and restore defaults
- Prints confirmation to stdout on success; exits non-zero with an error message on failure (e.g., provider not found, ambiguous match)

## Capabilities

### New Capabilities
- `switch-command`: Defines the behaviour of the `aura-cli switch <name>` subcommand for non-interactive provider activation

### Modified Capabilities
- `current-command`: Update help text to document the new `switch` command alongside `current`

## Impact

- `main.swift`: New argument parsing branch for `switch` subcommand (follows same pattern as `current`)
- `ProviderStore`: Reuses existing `activateProvider(_:)` and `deactivateAll()` methods
- `ConfigManager`: Reuses existing `updateEnvVariables(_:)` and `clearEnvVariables()` methods
- Help text (`--help` output) updated to list the new command
- No new dependencies required
