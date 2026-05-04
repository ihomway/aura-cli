## 1. Argument Parsing

- [x] 1.1 In `main.swift`, add detection of `"current"` as a subcommand argument (check `args.dropFirst().first == "current"`) after existing flag checks

## 2. Default Output

- [x] 2.1 Define a minimal `DefaultOutput` struct (or inline anonymous Codable) that encodes to `{"name":"Default"}`

## 3. Active Provider Output

- [x] 3.1 On `current` subcommand: call `ProviderStore.shared.load()` to populate the store
- [x] 3.2 Read `ProviderStore.shared.activeProvider`
- [x] 3.3 If `activeProvider` is non-nil, encode it with `JSONEncoder(.prettyPrinted)` and print to stdout
- [x] 3.4 If `activeProvider` is nil, encode `DefaultOutput` and print to stdout
- [x] 3.5 Call `exit(0)` after printing (no TUI launch)

## 4. Help Text Update

- [x] 4.1 Add `current` subcommand description to the `--help` output in `main.swift`
