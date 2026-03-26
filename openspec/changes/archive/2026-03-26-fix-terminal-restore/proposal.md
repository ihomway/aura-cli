## Why

After `aura-cli` exits, the shell prompt renders with incorrect horizontal indentation. The root cause is that pressing `q` (or any direct-exit path) calls `exit(0)` immediately, bypassing TauTUI's terminal-restore routine. The terminal is left in a partially-modified state — cursor position, alternate screen, or raw-mode settings are not reset — which shifts the next prompt to the wrong column.

## What Changes

- Add a `onQuit: () -> Void` callback to `AppComponent` (alongside the existing `requestRender`)
- Replace all `exit(0)` calls inside `AppComponent` with `onQuit()`
- In `main.swift`, wire `appComponent.onQuit` to call `tui.stop()` then `exit(0)`, giving TauTUI the chance to restore the terminal before the process exits

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `tui-framework`: The quit path now goes through TauTUI's `stop()` before `exit(0)`, satisfying the requirement that terminal state is restored on exit.

## Impact

- `Sources/aura-cli/Views/AppComponent.swift` — add `onQuit` callback, replace `exit(0)` usages
- `Sources/aura-cli/main.swift` — wire `appComponent.onQuit`
- No changes to models, services, or ViewModel
