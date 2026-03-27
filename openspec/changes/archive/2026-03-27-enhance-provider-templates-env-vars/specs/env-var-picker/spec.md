## ADDED Requirements

### Requirement: Env-var picker screen is reachable from the provider form
When the user navigates to the `[+ Add env var]` button on the add-form or edit-form screen and presses Enter, the app SHALL navigate to the `.envVarPicker` screen.

#### Scenario: Opening the picker from the add form
- **WHEN** the user is on the add-form screen with the cursor on `[+ Add env var]` and presses Enter
- **THEN** the app navigates to the env-var picker screen showing the first category selected

#### Scenario: Opening the picker from the edit form
- **WHEN** the user is on the edit-form screen with the cursor on `[+ Add env var]` and presses Enter
- **THEN** the app navigates to the env-var picker screen showing the first category selected

### Requirement: Picker screen displays categories as navigable tabs
The picker screen SHALL display the 9 category names as a horizontal tab bar at the top. The currently selected category tab SHALL be visually distinguished (e.g. `[Category]` vs ` Category `). Left/Right arrow keys SHALL move between categories.

#### Scenario: Navigating categories with arrow keys
- **WHEN** the user presses the Right arrow key on the picker screen
- **THEN** the next category tab becomes selected and its variables are listed

#### Scenario: Category wrapping at boundaries
- **WHEN** the user presses Right on the last category or Left on the first category
- **THEN** the selection does not move past the boundary (no wrap)

#### Scenario: All 9 categories are present
- **WHEN** the picker screen is displayed
- **THEN** the following 9 tabs are shown in order: API Authentication, Model Configuration, Bash Configuration, Claude Code Configuration, Feature Toggles, Proxy Configuration, MCP Configuration, Thinking Configuration, Miscellaneous

### Requirement: Picker lists variables for the selected category
The picker screen SHALL display the env-var names and short descriptions for the currently selected category. Up/Down arrow keys SHALL move the item cursor within the list.

#### Scenario: Items are shown for the selected category
- **WHEN** the user selects the "Bash Configuration" category tab
- **THEN** the item list shows the variables BASH_DEFAULT_TIMEOUT_MS, BASH_MAX_OUTPUT_LENGTH, BASH_MAX_TIMEOUT_MS, CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR

#### Scenario: Item cursor stays in bounds
- **WHEN** the user presses Down on the last item
- **THEN** the cursor does not move past the last item

### Requirement: Picker resets item cursor on category change
When the user switches categories, the item cursor SHALL reset to the first item in the new category.

#### Scenario: Cursor resets after category switch
- **WHEN** the user moves to a different category via Left/Right arrows
- **THEN** the item cursor is positioned on the first item of the new category

### Requirement: Selecting a variable adds it to the form and returns
Pressing Enter on a highlighted variable in the picker SHALL add that variable (with its default value or empty string) to the provider form's extra env-var list and navigate back to the form screen.

#### Scenario: Variable is added on Enter
- **WHEN** the user presses Enter on a highlighted env variable in the picker
- **THEN** the variable's key and default value are appended to the extra env-var list and the form screen is shown

#### Scenario: Already-present variables are skipped
- **WHEN** a variable is already in the core fields or extra env-vars list
- **THEN** that variable is not selectable (shown greyed out) and pressing Enter on it has no effect

### Requirement: Pressing Escape in the picker returns to the form without changes
If the user presses Escape on the picker screen, the app SHALL navigate back to the form screen without modifying the extra env-var list.

#### Scenario: Escape cancels the picker
- **WHEN** the user presses Escape on the env-var picker screen
- **THEN** the app returns to the form screen and no new env var is added
