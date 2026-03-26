## Why

SwiftTUI (`rensbreur/SwiftTUI`) has had no updates for over 2 years and is effectively unmaintained, creating risk of breakage with future Swift/macOS versions and leaving bugs unfixed. TauTUI (`steipete/TauTUI`) is an actively maintained fork that restores long-term viability for the project's TUI layer.

## What Changes

- Replace the `SwiftTUI` package dependency in `Package.swift` with `TauTUI`
- Update all `import SwiftTUI` statements across view files to `import TauTUI`
- Verify and reconcile any API differences between SwiftTUI and TauTUI (entry point, view modifiers, property wrappers)
- Update `Application` initialization in `main.swift` to match TauTUI's entry point API if it differs

## Capabilities

### New Capabilities

_None — this is a dependency swap with no new user-facing capabilities._

### Modified Capabilities

- `tui-framework`: The underlying TUI rendering framework is being replaced. SwiftTUI-specific APIs (`Application`, `View`, `@ObservedObject`, `@State`, `Button`, `TextField`, etc.) must be verified against TauTUI's surface. Any breaking API differences require adaptation in the view layer.

## Impact

- **`Package.swift`**: dependency URL and product name change
- **All files under `Sources/aura-cli/Views/`** (`RootView.swift`, `ProviderListView.swift`, `AddProviderView.swift`, `EditProviderView.swift`, `DeleteConfirmView.swift`): `import SwiftTUI` → `import TauTUI`
- **`Sources/aura-cli/main.swift`**: `import SwiftTUI`, `Application` init / `app.start()` call
- **`Sources/aura-cli/ViewModels/AppViewModel.swift`**: any SwiftTUI-specific ObservableObject/property wrapper imports
- No changes to models, services, or data layer
