## Why

Users naturally try `aura-cli switch Default` to return to the logged-in Claude account, mirroring the `"Default"` name shown by `aura-cli current` when no aura-managed provider is active. Today this fails with `Error: no provider found matching "Default"` because deactivation is only reachable via the `--off` flag — leaving an obvious, discoverable command path broken.

## What Changes

- `aura-cli switch Default` (case-insensitive) SHALL behave identically to `aura-cli switch --off`: deactivate any active provider, clear env variables in `~/.claude/settings.json`, and print the same "default" success message.
- The reserved name `Default` is matched before the provider lookup, so even a user-created provider literally named "Default" cannot shadow it.
- `--help` text for `switch` is updated to document `Default` as an accepted name alongside `--off`.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `switch-command`: add a reserved-name path so `switch Default` deactivates all providers instead of erroring.

## Impact

- Affected code: `Sources/aura-cli/main.swift` (the `switch` argument-handling block, lines ~65–112, and the `--help` text around lines ~29–33).
- No data-format or settings-file changes; the reserved name is purely an input-parsing rule.
- No new dependencies. No breaking changes — `--off` continues to work unchanged, and previously failing input becomes successful.
