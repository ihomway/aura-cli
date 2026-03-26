## 1. Update Package Dependency

- [x] 1.1 Fetch TauTUI's `Package.swift` from `https://github.com/steipete/TauTUI` to confirm the exact package product name and minimum swift-tools-version
- [x] 1.2 Update `Package.swift`: replace `rensbreur/SwiftTUI` URL with `steipete/TauTUI` and update the product name if it differs from `SwiftTUI`
- [x] 1.3 Run `swift package resolve` and confirm TauTUI resolves without errors

## 2. Update Imports

- [x] 2.1 Replace `import SwiftTUI` with `import TauTUI` in `Sources/aura-cli/main.swift`
- [x] 2.2 Replace `import SwiftTUI` with `import TauTUI` in `Sources/aura-cli/Views/RootView.swift`
- [x] 2.3 Replace `import SwiftTUI` with `import TauTUI` in `Sources/aura-cli/Views/ProviderListView.swift`
- [x] 2.4 Replace `import SwiftTUI` with `import TauTUI` in `Sources/aura-cli/Views/AddProviderView.swift`
- [x] 2.5 Replace `import SwiftTUI` with `import TauTUI` in `Sources/aura-cli/Views/EditProviderView.swift`
- [x] 2.6 Replace `import SwiftTUI` with `import TauTUI` in `Sources/aura-cli/Views/DeleteConfirmView.swift`
- [x] 2.7 Check `Sources/aura-cli/ViewModels/AppViewModel.swift` for any SwiftTUI import and replace if present

## 3. Build and Fix API Differences

- [x] 3.1 Run `swift build` and record all compiler errors
- [x] 3.2 Resolve any `Application` entry-point API differences in `main.swift` (init signature, `start()` method)
- [x] 3.3 Verify the `Button(action:hover:)` overload used in `ProviderListView` exists in TauTUI; adapt hover tracking if the overload is missing
- [x] 3.4 Verify `ObservableObject` / `@Published` are accessible via TauTUI (or add `import Combine` to `AppViewModel.swift` if not re-exported)
- [x] 3.5 Fix any remaining compiler errors from the build output
- [x] 3.6 Confirm `swift build` completes with zero errors

## 4. Smoke Test

- [x] 4.1 Run `swift run aura-cli --version` and confirm correct output
- [x] 4.2 Run `swift run aura-cli --help` and confirm correct output
- [x] 4.3 Run `swift run aura-cli` and verify the provider list screen renders
- [x] 4.4 Verify keyboard navigation (↑/↓) and provider activation work on the list screen
- [x] 4.5 Navigate Add → select template → fill form → Save and confirm a provider is added
- [x] 4.6 Navigate Edit on an existing provider, modify a field, save, and confirm the change persists
- [x] 4.7 Navigate Delete on an existing provider, confirm, and verify it is removed
