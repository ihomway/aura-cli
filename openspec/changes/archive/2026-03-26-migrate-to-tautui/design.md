## Context

aura-cli uses SwiftTUI (`rensbreur/SwiftTUI`, pinned to `branch: main`) as its sole TUI rendering dependency. SwiftTUI has been unmaintained for 2+ years. TauTUI (`steipete/TauTUI`) is a maintained fork that targets the same SwiftUI-like API surface. Because TauTUI originated as a fork of SwiftTUI, most of its public API is source-compatible, making this primarily a package swap with targeted adaptation where APIs diverge.

Affected surface:
- `Package.swift` — one dependency declaration
- 5 view files — `import SwiftTUI`
- `main.swift` — `import SwiftTUI` + `Application` entry point
- `AppViewModel.swift` — `import SwiftTUI` (for `ObservableObject` / `@Published` if re-exported)

## Goals / Non-Goals

**Goals:**
- Replace the unmaintained SwiftTUI package with TauTUI
- Preserve all existing TUI behavior exactly (no visible changes to the user)
- Ensure the app builds and runs correctly against TauTUI

**Non-Goals:**
- Adding new TUI features or improving UX as part of this change
- Changing any business logic, services, or data layer
- Removing the `@StateObject` workaround in `main.swift` (noted in code comment — tracked separately)

## Decisions

### 1. Direct package swap, not an abstraction layer

**Decision**: Update `Package.swift` to point at TauTUI and update `import` statements. Do not introduce an adapter/shim layer.

**Rationale**: TauTUI is a direct fork of SwiftTUI targeting the same API. An abstraction layer adds complexity with no benefit for a single-framework app. If the API diverges significantly in the future, a shim can be added at that time.

**Alternative considered**: Wrapping SwiftTUI/TauTUI types behind a local `TUIKit` module — rejected as over-engineering for this case.

### 2. Verify TauTUI API surface before adapting

**Decision**: After swapping the dependency, attempt a build and address any compiler errors as targeted fixes rather than pre-emptively rewriting view code.

**Rationale**: Since TauTUI is a fork, most APIs will compile as-is. Proactively rewriting untested divergences risks introducing regressions.

**Key APIs to verify**: `Application(rootView:)` + `app.start()`, `@ObservedObject`, `TextField` closure signature, `Button(action:hover:)` overload (used in `ProviderListView`).

### 3. Minimum Swift tools version

**Decision**: Keep `swift-tools-version: 5.9` unless TauTUI requires a higher version.

**Rationale**: Avoid bumping the toolchain requirement unless forced. Check TauTUI's own `Package.swift` for its minimum.

## Risks / Trade-offs

- **API divergence** → TauTUI may have renamed or removed types used by aura-cli. Mitigation: build immediately after the swap and fix compiler errors surgically.
- **Behavioral differences** → TauTUI may render or handle keyboard input differently despite API compatibility. Mitigation: manual smoke-test all screens (list, add, edit, delete, template select) after migration.
- **TauTUI stability** → Being maintained doesn't guarantee it's more stable. Mitigation: acceptable trade-off vs. a frozen library that will never receive fixes.
- **No `hover:` on Button** → The `Button(action:hover:)` overload used in `ProviderListView` may not exist in TauTUI. Mitigation: if missing, replace hover tracking with an explicit `@State` + `onHover` modifier or equivalent TauTUI API.

## Migration Plan

1. Update `Package.swift`: change URL from `rensbreur/SwiftTUI` to `steipete/TauTUI`, update product name if different
2. Run `swift package resolve` to pull TauTUI
3. Replace `import SwiftTUI` with `import TauTUI` in all affected files
4. Run `swift build` — fix any compiler errors
5. Run `swift run aura-cli` — smoke-test all screens manually
6. Verify `--version` and `--help` flags still work

**Rollback**: revert `Package.swift` and imports; `swift package resolve` restores SwiftTUI.

## Open Questions

- Does TauTUI export `ObservableObject` / `@Published` (re-exported from Combine/Observation), or does `AppViewModel` need a separate `import Combine`?
- Does TauTUI support the `Button(action:hover:)` overload used for hover tracking in `ProviderListView`?
- What is TauTUI's exact package product name (likely `TauTUI` — confirm in its `Package.swift`)?
