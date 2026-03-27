## Why

aura-cli ships with a fixed set of built-in provider templates (Anthropic, Zhipu AI, z.ai, Moonshot AI, Other/Custom). MiniMax is a commercially available LLM API provider with an Anthropic-compatible endpoint; adding it as a first-class template lets users onboard without manually entering every field.

## What Changes

- Add a `minimax` case to the `ProviderTemplate` enum with its seven pre-configured environment variables and default values.
- Wire the new template into the template-selection screen so users can pick "MiniMax" from the list.
- Assign an appropriate icon via `ProviderStore.inferIcon(from:)` for the MiniMax base URL domain.

## Capabilities

### New Capabilities

- `minimax-provider-template`: A built-in provider template for MiniMax with pre-filled `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, model name defaults, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` (boolean stored as `"1"`/`"0"`), and `API_TIMEOUT_MS`.

### Modified Capabilities

<!-- No existing spec-level requirements change. -->

## Impact

- **`ProviderTemplate.swift`** — new enum case with default env-var map.
- **Template selection screen** — `AppComponent` renders the additional template in the pick list; no structural changes needed.
- **`ProviderStore.inferIcon`** — domain `api.minimaxi.com` mapped to a suitable icon name.
- No breaking changes; existing providers and workflows are unaffected.
