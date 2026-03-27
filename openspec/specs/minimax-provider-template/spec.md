## ADDED Requirements

### Requirement: MiniMax template exists in allTemplates

The system SHALL include a `minimax` static constant in `ProviderTemplate` with the following default environment variables:

- `ANTHROPIC_BASE_URL`: `"https://api.minimaxi.com/anthropic"`
- `ANTHROPIC_AUTH_TOKEN`: `""` (empty, user must fill)
- `ANTHROPIC_DEFAULT_HAIKU_MODEL`: `"MiniMax-M2.7"`
- `ANTHROPIC_DEFAULT_SONNET_MODEL`: `"MiniMax-M2.7"`
- `ANTHROPIC_DEFAULT_OPUS_MODEL`: `"MiniMax-M2.7"`
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`: `"1"` (string representation of boolean true)
- `API_TIMEOUT_MS`: `"3000000"`

The template SHALL be named `"MiniMax"` and SHALL appear in `allTemplates` before the `other` template.

#### Scenario: MiniMax template is available in template selection

- **WHEN** user navigates to the "Select Template" screen
- **THEN** system displays "MiniMax" as an option in the template list

#### Scenario: MiniMax template pre-fills all seven env vars

- **WHEN** user selects the MiniMax template and proceeds to the add-provider form
- **THEN** system pre-populates all seven environment variable fields with the default values specified above

### Requirement: MiniMax base URL maps to an icon

The system SHALL recognize `api.minimaxi.com` in `ProviderStore.inferIcon(from:)` and return an appropriate icon identifier.

#### Scenario: Icon inference for MiniMax base URL

- **WHEN** `inferIcon(from:)` is called with `"https://api.minimaxi.com/anthropic"`
- **THEN** system returns a non-generic icon identifier (or `"OtherLogo"` as fallback until a dedicated asset is added)

### Requirement: CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC stored as string

The system SHALL store the boolean flag `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` as a string: `"1"` for true, `""` (empty) or omitted for false.

#### Scenario: Default value is "1"

- **WHEN** user creates a provider from the MiniMax template without editing the field
- **THEN** system writes `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1"` to the provider record

#### Scenario: User can clear the field to disable

- **WHEN** user edits the `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` field to an empty string
- **THEN** system treats the flag as false (disabled)
