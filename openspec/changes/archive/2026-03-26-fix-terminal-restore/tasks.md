## 1. AppComponent — add onQuit callback

- [x] 1.1 Add `var onQuit: () -> Void = {}` property to `AppComponent` (next to `requestRender`)
- [x] 1.2 Replace the `exit(0)` call in `handleList(input:)` with `onQuit()`

## 2. main.swift — wire onQuit

- [x] 2.1 Set `appComponent.onQuit` to `{ MainActor.assumeIsolated { tui.stop() }; exit(0) }` alongside the other callback wiring

## 3. Verify

- [x] 3.1 Run `swift build` and confirm it compiles cleanly
- [ ] 3.2 Run `swift run aura-cli`, press `q`, and confirm the shell prompt renders at the correct column with no extra indentation
