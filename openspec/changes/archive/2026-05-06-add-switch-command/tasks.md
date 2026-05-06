## 1. Argument Parsing

- [x] 1.1 Add `switch` subcommand detection in `main.swift` (after `current`, before TUI init)
- [x] 1.2 Parse the provider name argument (positional) and `--off` flag
- [x] 1.3 Handle missing argument case: print usage to stderr, exit 1

## 2. Core Switch Logic

- [x] 2.1 Run `ConfigImportService.syncOnStartup()` before provider lookup
- [x] 2.2 Implement provider name lookup (case-insensitive match against `ProviderStore.shared.providers`)
- [x] 2.3 Handle not-found case: print error to stderr, exit 1
- [x] 2.4 Handle multiple-match case: print error with matching names to stderr, exit 1
- [x] 2.5 Activate matched provider: call `ProviderStore.shared.activateProvider(_:)` then `ConfigManager.shared.updateEnvVariables(_:)`
- [x] 2.6 Print confirmation to stdout: `Switched to "<name>"`

## 3. Deactivation (--off)

- [x] 3.1 Implement `--off` flag handling: call `ProviderStore.shared.deactivateAll()` then `ConfigManager.shared.clearEnvVariables()`
- [x] 3.2 Print appropriate message based on whether a provider was previously active

## 4. Help Text Update

- [x] 4.1 Add `switch` command to the `--help` output COMMANDS section with description
