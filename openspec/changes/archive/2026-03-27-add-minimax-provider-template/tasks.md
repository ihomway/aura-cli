## 1. Add MiniMax provider template

- [x] 1.1 Add a `minimax` static `ProviderTemplate` constant to `Sources/aura-cli/Models/Models.swift` with all seven default env vars (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1"`, `API_TIMEOUT_MS: "3000000"`) and `icon: "OtherLogo"`.
- [x] 1.2 Insert `.minimax` into the `allTemplates` array before `.other`.

## 2. Update icon inference

- [x] 2.1 Add a `minimaxi.com` hostname check in `ProviderStore.inferIcon(from:)` returning `"OtherLogo"` (or a dedicated icon name when an asset is available).

## 3. Verify

- [x] 3.1 Build the project (`swift build`) and confirm no compiler errors.
- [x] 3.2 Run the app (`swift run aura-cli`), open the "Select Template" screen, and verify "MiniMax" appears in the list before "Other".
- [x] 3.3 Select the MiniMax template and confirm all seven env-var fields are pre-filled with correct defaults in the add-provider form.
