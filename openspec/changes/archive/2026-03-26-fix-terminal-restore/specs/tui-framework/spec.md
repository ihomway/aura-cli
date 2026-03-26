## MODIFIED Requirements

### Requirement: Terminal state is restored on exit
When the user quits the application, the terminal SHALL be fully restored to its pre-launch state before the process exits. This includes cursor visibility, raw-mode settings, and ANSI state.

#### Scenario: Shell prompt renders correctly after quit
- **WHEN** the user launches `aura-cli`, navigates the TUI, then presses `q` to quit
- **THEN** the shell prompt on the next line is rendered at the correct horizontal position with no extra indentation

#### Scenario: TauTUI stop is called before process exit
- **WHEN** the quit key (`q`) is pressed
- **THEN** `TUI.stop()` is invoked before `exit(0)`, allowing TauTUI to restore terminal settings
