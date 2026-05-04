## ADDED Requirements

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

#### Scenario: No side effects
- **WHEN** `aura-cli current` is run
- **THEN** no files are written or modified, and the TUI is never started
