# Spec: current-command

## Purpose

Defines the behaviour of the `aura-cli current` subcommand, which prints the active provider configuration as JSON and exits without launching the TUI.

## Requirements

### Requirement: Print active provider as JSON
When invoked as `aura-cli current`, the CLI SHALL print the active provider's full configuration as pretty-printed JSON to stdout and exit with code 0.

#### Scenario: Active aura-managed provider
- **WHEN** a provider is active (its `isActive` flag is true in `~/.claude/aura-providers.json`)
- **THEN** the output SHALL be a JSON object containing `name`, `icon`, `isActive`, `envVariables`, and `id` fields matching the stored provider

#### Scenario: No aura provider active (default Claude account)
- **WHEN** no aura-managed provider is active
- **THEN** the output SHALL be `{"name":"Default"}` with no other fields

#### Scenario: Providers file absent
- **WHEN** `~/.claude/aura-providers.json` does not exist
- **THEN** the output SHALL be `{"name":"Default"}` (treated as default state)

### Requirement: Exit cleanly without launching TUI
The `current` subcommand SHALL resolve, print, and exit before the TUI is initialised. It SHALL NOT trigger `ConfigImportService.syncOnStartup()` or any write operations.

The `--help` output SHALL list `switch` alongside `current` in the COMMANDS section.

#### Scenario: No side effects
- **WHEN** `aura-cli current` is run
- **THEN** no files are written or modified, and the TUI is never started

#### Scenario: Help text includes switch command
- **WHEN** `aura-cli --help` is run
- **THEN** the COMMANDS section SHALL list both `current` and `switch` with brief descriptions
