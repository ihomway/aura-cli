## ADDED Requirements

### Requirement: Form displays extra env-var fields below the 8 core fields
The add-form and edit-form screens SHALL display any extra env variables (beyond the 8 core fields) as additional editable rows between the core fields and the action buttons. Each row shows the env-var key name and the current value.

#### Scenario: Extra env var row is visible after adding
- **WHEN** the user adds an env variable via the picker and returns to the form
- **THEN** a new row showing `<KEY>: <value>▌` appears below the core fields

#### Scenario: Multiple extra vars are shown
- **WHEN** the user has added two extra env variables
- **THEN** both rows appear in the order they were added

### Requirement: Extra env-var fields are editable like core fields
When the cursor is on an extra env-var value field, the user SHALL be able to type characters and use Backspace to edit the value, matching the behaviour of the core fields.

#### Scenario: Typing into an extra field
- **WHEN** the cursor is on an extra env-var field and the user types a character
- **THEN** the character is appended to that field's value

#### Scenario: Backspace removes last character
- **WHEN** the cursor is on an extra env-var field with a non-empty value and the user presses Backspace
- **THEN** the last character is removed from the value

### Requirement: An extra env-var field is removed when Backspace is pressed on an empty value
If an extra env-var field's value is already empty and the user presses Backspace, that entry SHALL be removed from the extra env-var list entirely.

#### Scenario: Deleting an empty extra field
- **WHEN** the cursor is on an extra env-var field whose value is empty and the user presses Backspace
- **THEN** the extra env-var entry is removed from the list and the cursor moves to the previous field

### Requirement: "[+ Add env var]" button appears below extra fields
The form screen SHALL show an `[+ Add env var]` button after all extra env-var fields and before the `[Save]` and `[Back]` buttons.

#### Scenario: Button is always visible on the form
- **WHEN** the form screen is displayed (add or edit)
- **THEN** the `[+ Add env var]` button is present below any extra env-var rows

#### Scenario: Button cursor navigates to it
- **WHEN** the user navigates down past the last extra env-var field (or past field 7 if no extras)
- **THEN** the cursor lands on `[+ Add env var]`

### Requirement: Extra env vars are included when the form is saved
When the user saves the form (presses Enter on `[Save]`), all extra env-var key/value pairs SHALL be included in the provider's `envVariables` dictionary alongside the core fields.

#### Scenario: Extra vars persist on save
- **WHEN** the user adds `HTTP_PROXY=http://proxy:8080` as an extra env var and saves the form
- **THEN** the new provider (or updated provider) contains `HTTP_PROXY: "http://proxy:8080"` in its envVariables

### Requirement: Editing an existing provider populates extra env-var fields
When the user opens an existing provider for editing, any env variables not in the 8 core keys SHALL be loaded into the extra env-var list.

#### Scenario: Extra vars are loaded for edit
- **WHEN** a provider has `HTTP_PROXY` set and the user opens it for editing
- **THEN** `HTTP_PROXY` appears as an extra env-var field pre-populated with its value
