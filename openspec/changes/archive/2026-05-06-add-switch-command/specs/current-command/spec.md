## MODIFIED Requirements

### Requirement: Exit cleanly without launching TUI
The `current` subcommand SHALL resolve, print, and exit before the TUI is initialised. It SHALL NOT trigger `ConfigImportService.syncOnStartup()` or any write operations.

The `--help` output SHALL list `switch` alongside `current` in the COMMANDS section.

#### Scenario: No side effects
- **WHEN** `aura-cli current` is run
- **THEN** no files are written or modified, and the TUI is never started

#### Scenario: Help text includes switch command
- **WHEN** `aura-cli --help` is run
- **THEN** the COMMANDS section SHALL list both `current` and `switch` with brief descriptions
