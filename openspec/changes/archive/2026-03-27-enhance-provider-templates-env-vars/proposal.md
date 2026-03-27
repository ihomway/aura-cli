## Why

The current add/edit provider form in aura-cli is hardcoded to 8 fields (name, base URL, auth token, haiku/sonnet/opus model, disable-traffic, timeout), but Claude Code supports dozens of environment variables across multiple categories. Users who need proxy settings, MCP configuration, thinking tokens, bash timeouts, or other advanced variables have no way to configure them through the TUI — they must edit `~/.claude/settings.json` manually. Additionally, the provider template list is sparse compared to the providers supported by the Prism app, and templates lack the richer env-var defaults they carry there.

## What Changes

- **Add provider templates**: Add missing templates present in Prism — DeepSeek, PackyCode, Aliyuncs, ModelScope, LongCat, AnyRouter, MiniMax.io, Vanchin, ZenMux.
- **Update existing templates**: Sync existing templates (zhipuAI, zai, moonshotAI, minimax) with Prism's updated defaults and extra env vars (e.g., `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, `API_TIMEOUT_MS`).
- **Add "Add other env vars" action**: In the add-form and edit-form screens, add an `[+ Add env var]` button below the core fields. Activating it opens a new `envVarPicker` screen.
- **New env-var picker screen**: A categorized, navigable screen listing all Claude Code env variables grouped into 9 tabs/categories: API Authentication, Model Configuration, Bash Configuration, Claude Code Configuration, Feature Toggles, Proxy Configuration, MCP Configuration, Thinking Configuration, Miscellaneous. The user selects a variable, which is added to the provider's extra env-var list and returns to the form.
- **Extra env-var fields on form**: The form shows core fields (name, url, token, haiku, sonnet, opus, no-traffic, timeout) plus any extra env vars added via the picker. Each extra field is editable and deletable (delete key removes the entry when value is empty).
- **New `AppScreen` case**: `.envVarPicker` to hold navigation state for the picker.

## Capabilities

### New Capabilities
- `env-var-picker`: Categorized TUI screen for browsing and selecting Claude env variables grouped by category, navigable with arrow keys and tab-like category switching.
- `extra-env-vars-in-form`: Form screen support for a dynamic list of extra env-var fields beyond the core 8, with add and delete capability.

### Modified Capabilities
- `provider-templates`: Extended set of provider templates matching Prism's `allTemplates`, with richer default env vars.

## Impact

- `Sources/aura-cli/Models/Models.swift`: Add new `ProviderTemplate` entries; add `ClaudeEnvCategory` enum grouping `ClaudeEnvVariable` definitions (ported from Prism's `ClaudeEnvVariable.allVariables`); add `.envVarPicker` to `AppScreen`.
- `Sources/aura-cli/Views/AppComponent.swift`: Add `envVarPickerCategoryIndex`, `envVarPickerItemIndex` state; add render/handle methods for the picker screen; update form render/handle to support extra env-var rows and the `[+ Add env var]` button; update `loadFormForAdd`/`loadFormForEdit`/`buildEnvVars` to include extra fields.
- No changes to services, persistence, or CLI entry point.
