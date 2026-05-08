# Spec: switch-command

## Purpose

Defines the behaviour of the `aura-cli switch` subcommand, which activates a provider by name or deactivates all providers, without launching the TUI.
## Requirements
### Requirement: Switch provider by name
When invoked as `aura-cli switch <name>`, the CLI SHALL activate the provider whose name matches `<name>` (case-insensitive), write its env variables to `~/.claude/settings.json`, and exit with code 0. The reserved name `Default` (case-insensitive) is excluded from this lookup; see "Reserved name 'Default' deactivates all providers".

#### Scenario: Exact match (case-insensitive)
- **WHEN** `aura-cli switch "zhipu ai"` is run and a provider named "Zhipu AI" exists
- **THEN** that provider SHALL be activated, its env variables written to settings.json, and stdout SHALL print `Switched to "Zhipu AI"`

#### Scenario: Provider not found
- **WHEN** `aura-cli switch "nonexistent"` is run, the input is not the reserved name `Default`, and no provider name matches
- **THEN** stderr SHALL print `Error: no provider found matching "nonexistent"` and exit with code 1

#### Scenario: Multiple providers match
- **WHEN** `aura-cli switch "api"` is run and multiple provider names match (case-insensitive equality)
- **THEN** stderr SHALL print `Error: multiple providers match "api":` followed by the matching names, and exit with code 1

### Requirement: Deactivate all providers
When invoked as `aura-cli switch --off`, the CLI SHALL deactivate all providers, clear env variables from `~/.claude/settings.json`, and exit with code 0.

#### Scenario: Deactivate with active provider
- **WHEN** `aura-cli switch --off` is run and a provider is currently active
- **THEN** all providers SHALL be deactivated, env variables cleared from settings.json, and stdout SHALL print `Switched to default (all providers deactivated)`

#### Scenario: Deactivate with no active provider
- **WHEN** `aura-cli switch --off` is run and no provider is active
- **THEN** stdout SHALL print `Already on default (no active provider)` and exit with code 0

### Requirement: Run startup sync before switching
The `switch` subcommand SHALL run `ConfigImportService.syncOnStartup()` before performing any activation or deactivation to ensure provider state is reconciled.

#### Scenario: Sync runs before activation
- **WHEN** `aura-cli switch "MyProvider"` is run
- **THEN** `ConfigImportService.syncOnStartup()` SHALL execute before the provider is looked up and activated

### Requirement: Missing name argument
When invoked as `aura-cli switch` with no name and no `--off` flag, the CLI SHALL print usage information and exit with code 1.

#### Scenario: No argument provided
- **WHEN** `aura-cli switch` is run with no additional arguments
- **THEN** stderr SHALL print `Usage: aura-cli switch <name> | --off` and exit with code 1

### Requirement: Reserved name "Default" deactivates all providers
When invoked as `aura-cli switch Default` (case-insensitive), the CLI SHALL behave identically to `aura-cli switch --off`: deactivate any active provider, clear env variables in `~/.claude/settings.json`, and exit with code 0. The reserved-name check SHALL run before the provider lookup, so a user-created provider literally named "Default" cannot intercept this behavior.

#### Scenario: Switch to Default with active provider
- **WHEN** `aura-cli switch Default` is run and a provider is currently active
- **THEN** all providers SHALL be deactivated, env variables cleared from settings.json, and stdout SHALL print `Switched to default (all providers deactivated)`

#### Scenario: Switch to default with no active provider
- **WHEN** `aura-cli switch default` is run and no provider is active
- **THEN** stdout SHALL print `Already on default (no active provider)` and exit with code 0

#### Scenario: Reserved name beats user-created "Default" provider
- **WHEN** `aura-cli switch Default` is run and a user-created provider named "Default" exists in `~/.claude/aura-providers.json`
- **THEN** the CLI SHALL deactivate all providers (treating the input as the reserved name) rather than activating the user-created provider, and SHALL NOT print `Switched to "Default"`

#### Scenario: Case-insensitive match on reserved name
- **WHEN** `aura-cli switch DEFAULT` is run
- **THEN** the CLI SHALL treat the input as the reserved name and deactivate all providers

