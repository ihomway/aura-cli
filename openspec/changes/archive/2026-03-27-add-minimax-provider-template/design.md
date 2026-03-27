## Context

aura-cli stores built-in provider templates as static `ProviderTemplate` instances in `Models.swift`. Each template carries a name, an icon identifier, and a dictionary of default environment variable key-value pairs. A companion `ProviderStore.inferIcon(from:)` function maps known base-URL hostnames to icon names so that providers created outside of a template still get the right logo.

The current `allTemplates` array drives the template-selection screen in `AppComponent`. Adding a new template therefore requires:

1. A new static `ProviderTemplate` constant.
2. An entry in `allTemplates`.
3. A hostname entry in `inferIcon`.

No architectural changes are required; this is a data-only addition.

## Goals / Non-Goals

**Goals:**
- Ship a `minimax` built-in template with all seven env-var defaults pre-filled.
- Surface the template in the provider-add flow with the correct icon.
- Map `api.minimaxi.com` in `inferIcon` so manually-created MiniMax providers also get the logo.

**Non-Goals:**
- Adding a custom MiniMax logo asset (will reuse `OtherLogo` or an existing asset until design provides one).
- Validating MiniMax API connectivity at runtime.
- Persisting or migrating existing provider records — the template only affects the creation flow.

## Decisions

### Decision 1 — Represent CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC as `"1"` in the default map

The env-var dictionary is `[String: String]`. The default value `true` maps to the string `"1"`. An empty string or omitted key represents `false`. The form screen already renders all keys as text fields, so the user can change `"1"` to `""` to disable the flag. No special boolean UI is needed for MVP.

**Alternatives considered:**
- Add a dedicated boolean field type to the form: increases scope significantly; deferred.

### Decision 2 — Icon: use `OtherLogo` until a MiniMax asset is added

Adding a new image asset (`.xcassets` entry or PNG) is outside the current scope. `OtherLogo` is the established fallback. Once a `MiniMaxLogo` asset is added, `inferIcon` and the template `icon` field can be updated in a follow-on change.

**Alternatives considered:**
- Reuse `ZhipuLogo` as a temporary placeholder: semantically incorrect.

### Decision 3 — Place `minimax` before `other` in `allTemplates`

The `other` template is always last as the generic fallback. MiniMax should slot in before it, consistent with how Moonshot AI and z.ai are ordered (alphabetical / add-order among non-Anthropic providers).

## Risks / Trade-offs

- [Icon placeholder] Using `OtherLogo` means MiniMax providers show a generic icon until a real asset is provided → Mitigation: file a follow-on task; `inferIcon` and template field are the only two touch points.
- [Default model names] MiniMax model identifiers may change over time → Mitigation: users can edit model fields after creation; defaults are non-normative.
