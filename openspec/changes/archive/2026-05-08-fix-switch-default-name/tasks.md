## 1. Implement reserved-name handling in `switch`

- [x] 1.1 In `Sources/aura-cli/main.swift`, inside the `if args.dropFirst().first == "switch"` block, define the reserved name as a local constant (`"Default"`) and detect it before the provider lookup.
- [x] 1.2 Treat a case-insensitive match against the reserved name the same as the existing `--off` branch: run `ConfigImportService.shared.syncOnStartup()`, capture `wasActive`, call `ProviderStore.shared.deactivateAll()` and `ConfigManager.shared.clearEnvVariables()`, and print either `Switched to default (all providers deactivated)` or `Already on default (no active provider)` exactly as `--off` does.
- [x] 1.3 Ensure the reserved-name branch runs before the `ProviderStore.shared.providers.filter { ... }` lookup so a user-created provider literally named "Default" cannot intercept it.
- [x] 1.4 Refactor the deactivation logic into a small local closure or helper inside `main.swift` so `--off` and the reserved name share one code path (single source of truth).

## 2. Update `--help` documentation

- [x] 2.1 In the `--help` text in `Sources/aura-cli/main.swift`, update the `switch` lines under `COMMANDS` to document `Default` as an accepted name. For example, add a line like `switch Default   Deactivate all providers (alias for --off)` directly below the existing `switch --off` line.

## 3. Manual verification

- [x] 3.1 Build with `swift build` and confirm no warnings.
- [x] 3.2 With an active provider, run `swift run aura-cli switch Default` and verify stdout is `Switched to default (all providers deactivated)` and exit code is 0.
- [x] 3.3 With no active provider, run `swift run aura-cli switch default` (lowercase) and verify stdout is `Already on default (no active provider)` and exit code is 0.
- [x] 3.4 Verify `swift run aura-cli switch DEFAULT` (uppercase) takes the same path.
- [x] 3.5 Confirm that an unrelated provider lookup (`swift run aura-cli switch nonexistent`) still prints `Error: no provider found matching "nonexistent"` to stderr and exits 1.
- [x] 3.6 Confirm `swift run aura-cli switch --off` continues to work unchanged.
- [x] 3.7 Run `swift run aura-cli current` after each of the above and confirm output toggles between the active provider's JSON and `{"name":"Default"}` as expected.
- [x] 3.8 Confirm `swift run aura-cli --help` shows the new `Default` line.

## 4. Spec sync

- [ ] 4.1 After implementation merges and is verified, archive the change with `openspec archive fix-switch-default-name` so `openspec/specs/switch-command/spec.md` picks up the ADDED and MODIFIED requirements.
