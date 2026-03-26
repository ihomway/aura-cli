## MODIFIED Requirements

### Requirement: TUI framework dependency is actively maintained
The app SHALL depend on an actively maintained TUI framework. The dependency MUST be sourced from `steipete/TauTUI` rather than the unmaintained `rensbreur/SwiftTUI`.

#### Scenario: Package resolves from TauTUI
- **WHEN** a developer runs `swift package resolve`
- **THEN** the resolved dependency is `TauTUI` from `steipete/TauTUI`, not `SwiftTUI` from `rensbreur/SwiftTUI`

#### Scenario: App builds successfully
- **WHEN** a developer runs `swift build`
- **THEN** the build succeeds with no errors related to the TUI framework import

### Requirement: All view files import TauTUI
Every Swift source file that previously imported `SwiftTUI` SHALL import `TauTUI` instead.

#### Scenario: No SwiftTUI imports remain
- **WHEN** the codebase is searched for `import SwiftTUI`
- **THEN** zero matches are found across all source files

#### Scenario: TauTUI import resolves correctly
- **WHEN** a file with `import TauTUI` is compiled
- **THEN** all previously-used TUI types (`View`, `Text`, `Button`, `VStack`, `HStack`, `ForEach`, `TextField`, `Application`) are available without error

### Requirement: Application entry point works with TauTUI
The `main.swift` entry point SHALL successfully launch the TUI using TauTUI's `Application` API.

#### Scenario: TUI launches on `swift run`
- **WHEN** the user runs `swift run aura-cli` without flags
- **THEN** the TUI renders the provider list screen in the terminal

#### Scenario: CLI flags still work
- **WHEN** the user runs `swift run aura-cli --version` or `swift run aura-cli --help`
- **THEN** the appropriate text is printed and the process exits before the TUI starts

### Requirement: Existing TUI behavior is preserved
All screens and interactions SHALL behave identically after the migration.

#### Scenario: Provider list renders and navigation works
- **WHEN** the TUI starts
- **THEN** the provider list, action buttons (Add / Edit / Delete / Quit), and status line render correctly, and keyboard navigation between items works

#### Scenario: Add provider flow completes
- **WHEN** the user navigates Add → select template → fill form → Save
- **THEN** the provider is saved and the list screen reflects the new provider

#### Scenario: Edit and delete flows complete
- **WHEN** the user selects Edit or Delete on a provider and confirms
- **THEN** the provider is updated or removed and the list reflects the change
