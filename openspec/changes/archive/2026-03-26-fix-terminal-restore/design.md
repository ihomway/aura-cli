## Context

`AppComponent` currently calls `exit(0)` directly in two places inside `handleList`:

```swift
case .key(.character("q"), _):
    exit(0)
```

`exit(0)` is a hard process termination — it unwinds C atexit handlers but does not give TauTUI's `TUI` object a chance to run its Swift-level teardown (`stop()`), which restores raw-mode terminal settings, re-shows the cursor, and resets ANSI state. The result is a misaligned shell prompt after the app closes.

TauTUI's `TUI` class already exposes `public func stop()` for exactly this purpose, and it sets `handlesControlC: Bool = true` by default so Ctrl+C is already handled correctly — only the programmatic `q` quit path is broken.

## Goals / Non-Goals

**Goals:**
- Ensure the terminal is fully restored when the user quits via `q`
- Keep the fix minimal: one new callback, two call-site changes

**Non-Goals:**
- Changing any other exit paths (Ctrl+C is already handled by TauTUI)
- Adding animated exit transitions or confirmation prompts

## Decisions

### Callback over direct TUI reference

**Decision**: Add `var onQuit: () -> Void = {}` to `AppComponent` (same pattern as `requestRender`) and wire it in `main.swift` to `{ tui.stop(); exit(0) }`.

**Rationale**: `AppComponent` intentionally has no direct reference to `TUI` — keeping it decoupled makes the component easier to test and reason about. The callback pattern is already established by `requestRender`.

**Alternative considered**: Pass `tui` directly into `AppComponent.init` — rejected as unnecessary coupling for a single use case.

## Risks / Trade-offs

- **`tui.stop()` is `@MainActor`** — the closure assigned to `onQuit` is called from `handle(input:)`, which runs on the main actor (TauTUI always dispatches input on the main actor). Using `MainActor.assumeIsolated` in the closure (same pattern as `requestRender`) is correct and safe.
- **Double-stop safety** — calling `stop()` followed immediately by `exit(0)` means no code runs after `stop()`. No risk of double-stop.
