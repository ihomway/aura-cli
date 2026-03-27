## ADDED Requirements

### Requirement: Additional provider templates are available
`ProviderTemplate.allTemplates` SHALL include the following providers in addition to the existing ones: DeepSeek, PackyCode, Aliyuncs, ModelScope, LongCat, AnyRouter, MiniMax.io, Vanchin (StreamLake), and ZenMux.

#### Scenario: DeepSeek template exists with correct defaults
- **WHEN** the user selects the DeepSeek template on the template-select screen
- **THEN** the add-form is pre-populated with base URL `https://api.deepseek.com/anthropic`, Haiku/Sonnet/Opus model `deepseek-chat`, `API_TIMEOUT_MS=600000`, and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`

#### Scenario: MiniMax.io template is distinct from MiniMax template
- **WHEN** the user views the template list
- **THEN** both "MiniMax" (api.minimaxi.com) and "MiniMax.io" (api.minimax.io) appear as separate entries

#### Scenario: All new templates appear in the template selection screen
- **WHEN** the user navigates to the template-select screen
- **THEN** DeepSeek, PackyCode, Aliyuncs, ModelScope, LongCat, AnyRouter, MiniMax.io, Vanchin, and ZenMux are listed alongside the existing templates

### Requirement: Existing templates are updated with richer defaults
The existing zhipuAI, zai, moonshotAI, and minimax templates SHALL carry any additional env var defaults present in Prism (e.g., `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, `API_TIMEOUT_MS`) if they are set in the Prism counterpart.

#### Scenario: MiniMax template carries timeout and traffic defaults
- **WHEN** the user selects the existing MiniMax template
- **THEN** `API_TIMEOUT_MS` is pre-populated with `3000000` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is pre-populated with `1`

### Requirement: ClaudeEnvVariable catalogue is available in Models
`Models.swift` SHALL define a `ClaudeEnvCategory` enum with 9 cases and a `ClaudeEnvVariable` struct with fields `name`, `shortName`, `description`, `type`, `defaultValue`, and `category`. A static `allVariables` array SHALL contain all variables for the 9 requested categories ported from Prism's catalogue.

#### Scenario: Variables are queryable by category
- **WHEN** code calls `ClaudeEnvVariable.variables(for: .bashConfiguration)`
- **THEN** the result contains BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, BASH_MAX_TIMEOUT_MS, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR

#### Scenario: All 9 categories are covered
- **WHEN** iterating `ClaudeEnvCategory.allCases`
- **THEN** the following cases are present: apiAuthentication, modelConfiguration, bashConfiguration, claudeCodeConfiguration, featureToggles, proxyConfiguration, mcpConfiguration, thinkingConfiguration, miscellaneous
