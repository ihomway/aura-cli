## 1. Models — ClaudeEnvVariable catalogue & categories

- [x] 1.1 Add `ClaudeEnvCategory` enum to `Models.swift` with 9 cases: `apiAuthentication`, `modelConfiguration`, `bashConfiguration`, `claudeCodeConfiguration`, `featureToggles`, `proxyConfiguration`, `mcpConfiguration`, `thinkingConfiguration`, `miscellaneous`; add `var displayName: String` computed property for each case
- [x] 1.2 Add `ClaudeEnvVariable` struct to `Models.swift` with fields `name: String`, `shortName: String`, `description: String`, `type: EnvValueType` (reuse or define `EnvValueType` enum: `.string`, `.integer`, `.boolean`), `defaultValue: String?`, `category: ClaudeEnvCategory`
- [x] 1.3 Add `ClaudeEnvVariable.allVariables: [ClaudeEnvVariable]` static array populated with all variables for the 9 categories, ported from Prism's `ClaudeEnvVariable.allVariables` (API Authentication, Model Configuration, Bash Configuration, Claude Code Configuration, Feature Toggles, Proxy Configuration, MCP Configuration, Thinking Configuration, Miscellaneous)
- [x] 1.4 Add `static func variables(for category: ClaudeEnvCategory) -> [ClaudeEnvVariable]` helper on `ClaudeEnvVariable`

## 2. Models — Provider templates update

- [x] 2.1 Add new `ProviderTemplate` static entries to `Models.swift`: `deepSeekAI`, `packyCodeAI`, `aliyuncsAI`, `modelScopeAI`, `longCatAI`, `anyRouterAI`, `miniMaxIoAI`, `vanchinAI`, `zenMuxAI` — using the same env var defaults as Prism's counterparts
- [x] 2.2 Update existing templates (`zhipuAI`, `zai`, `moonshotAI`, `minimax`) to include additional env vars present in Prism (e.g. `API_TIMEOUT_MS`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` where set)
- [x] 2.3 Update `ProviderTemplate.allTemplates` array to include all new templates (maintain `other` as last entry)

## 3. Models — AppScreen extension

- [x] 3.1 Add `.envVarPicker` case to the `AppScreen` enum in `Models.swift` (no associated value needed; picker state lives on `AppComponent`)
- [x] 3.2 Update `AppScreen.==` switch to handle the new case

## 4. AppComponent — Extra env-vars form state

- [x] 4.1 Add `extraEnvVars: [(key: String, value: String)]` property on `AppComponent` to hold dynamic extra fields
- [x] 4.2 Add computed properties `addEnvVarIndex: Int`, `saveIndex: Int`, `backIndex: Int` derived from `extraEnvVars.count` to keep index arithmetic in one place
- [x] 4.3 Update `loadFormForAdd(template:)` to clear `extraEnvVars`
- [x] 4.4 Update `loadFormForEdit(provider:)` to populate `extraEnvVars` from `provider.envVariables` keys not in the 8 core field keys
- [x] 4.5 Update `buildEnvVars()` to merge `extraEnvVars` key/value pairs into the returned dictionary

## 5. AppComponent — Form render update

- [x] 5.1 Update `renderForm(width:)` to render extra env-var rows after the 8 core fields, showing key name (truncated if needed) and editable value with cursor indicator
- [x] 5.2 Render the `[+ Add env var]` button row below extra fields (highlight when `formFieldIndex == addEnvVarIndex`)
- [x] 5.3 Update `[Save]` and `[Back]` button cursor checks to use `saveIndex` and `backIndex`

## 6. AppComponent — Form input handler update

- [x] 6.1 Update `handleForm(input:)` arrow-key navigation to respect the new dynamic `saveIndex`/`backIndex`/`addEnvVarIndex` upper bound
- [x] 6.2 Handle Enter on `addEnvVarIndex`: reset picker state and call `viewModel.navigate(to: .envVarPicker)`
- [x] 6.3 Handle Enter on `saveIndex`: call `submitForm()`
- [x] 6.4 Handle Enter on `backIndex`: call `navigateBack()`
- [x] 6.5 Handle character input and paste when cursor is on an extra env-var field index (index in range `8 ..< addEnvVarIndex`)
- [x] 6.6 Handle Backspace on an extra env-var field: remove last char; if value becomes empty after removal, remove the entry from `extraEnvVars` and decrement `formFieldIndex`

## 7. AppComponent — Env-var picker screen

- [x] 7.1 Add `pickerCategoryIndex: Int` and `pickerItemIndex: Int` properties on `AppComponent`; add `pickerOriginScreen: AppScreen` to remember which form to return to
- [x] 7.2 Implement `renderEnvVarPicker(width:)` method: render category tab bar (horizontal, highlight selected with brackets), then list items for the selected category showing key name and short description; grey-out (or mark with `·`) already-present keys
- [x] 7.3 Add `.envVarPicker` case to `render(width:)` dispatch switch
- [x] 7.4 Implement `handleEnvVarPicker(input:)`: Left/Right moves `pickerCategoryIndex` (reset `pickerItemIndex` to 0); Up/Down moves `pickerItemIndex`; Enter selects the highlighted variable (if not already present) — appends it to `extraEnvVars` with its `defaultValue ?? ""` and navigates back to the origin form; Escape navigates back without changes
- [x] 7.5 Add `.envVarPicker` case to `handle(input:)` dispatch switch

## 8. Build verification

- [x] 8.1 Run `swift build` and fix any compile errors
- [x] 8.2 Manually test: add a provider using a new template (e.g. DeepSeek), verify pre-populated fields
- [x] 8.3 Manually test: open picker, navigate categories, add `HTTP_PROXY`, confirm it appears in the form and is saved to the provider
- [x] 8.4 Manually test: edit an existing provider that has extra vars, confirm they appear in extra rows
- [x] 8.5 Manually test: delete an extra env-var by pressing Backspace until empty
