## Context

`Sources/aura-cli/main.swift` handles the `switch` subcommand by joining the trailing args into a name and looking it up in `ProviderStore.shared.providers` with a case-insensitive equality match. The string `"Default"` is meaningful elsewhere in the CLI: `aura-cli current` emits `{"name":"Default"}` when no aura-managed provider is active, so users reasonably expect `aura-cli switch Default` to be the inverse — a way back to the logged-in Claude account.

The current code path returns `Error: no provider found matching "Default"` because no provider with that name exists in `aura-providers.json`. The only existing way to reach the default state is `aura-cli switch --off`, which is a flag rather than a name and is not discoverable from the `current` output.

## Goals / Non-Goals

**Goals:**
- Accept `Default` (case-insensitive) as a switch target that deactivates all providers, equivalent to `--off`.
- Preserve the existing `--off` behavior and exit codes.
- Keep the reserved-name check ahead of provider lookup so a user-created provider literally named "Default" cannot override the deactivation behavior.
- Update `--help` text so the reserved name is documented next to `--off`.

**Non-Goals:**
- Introducing a separate "Default" entry in `~/.claude/aura-providers.json`. The default state is the absence of an active provider, not a stored record.
- Changing the JSON output of `current` or any other subcommand.
- Renaming or repurposing `--off`.
- Adding a generic alias system for reserved names beyond `Default`.

## Decisions

### Decision 1: Reserve `Default` at argument-parse time, not in `ProviderStore`
The check lives in `main.swift` immediately after the joined `name` is computed and before the `ProviderStore.shared.providers.filter` lookup. Rationale: the reserved name is a CLI concern (matches the `current` output contract), not a data-model concern. Putting it inside `ProviderStore` would couple a service to CLI naming and would also force the same handling on the TUI, where there is no notion of switching to "Default" by name.

**Alternative considered:** add a synthetic `Provider(name: "Default", …)` to `ProviderStore.providers`. Rejected — it would leak into the TUI provider list, the JSON file, and the duplicate-detection logic, and would create an inconsistency where activating "Default" actually means clearing all activations.

### Decision 2: Match case-insensitively, like the rest of `switch`
The existing `switch <name>` lookup is `name.lowercased() == ...lowercased()`. The reserved-name check uses the same comparison so `default`, `Default`, and `DEFAULT` all work, matching the spirit of the existing requirement.

### Decision 3: Reuse the exact `--off` code path and message
The reserved-name branch jumps to the same logic that `--off` runs today: `syncOnStartup()`, capture `wasActive`, `deactivateAll()`, `clearEnvVariables()`, and print either `Switched to default (all providers deactivated)` or `Already on default (no active provider)`. Rationale: a single source of truth for "go to default" — any future change to that behavior (e.g., backup-restore semantics) automatically applies to both spellings. Implementation-wise, this is most cleanly done by treating a reserved-name match the same as the `--off` flag in the same conditional.

### Decision 4: Do not block creating a provider literally named "Default" in the TUI
Adding a name-validation rule in the Add/Edit forms is out of scope. If such a provider exists, `aura-cli switch Default` will still deactivate (because the reserved-name check runs first), and the user can still edit/delete that provider from the TUI. This keeps the change surgical.

## Risks / Trade-offs

- **Risk:** A user has already created a provider named "Default" and relies on `aura-cli switch Default` activating it. → **Mitigation:** This is the bug being fixed — that command currently errors, so no existing behavior is being silently changed. The `--help` update calls out the reserved name. If the user wants to activate that provider non-interactively, they can rename it in the TUI.
- **Risk:** The reserved name diverges from what `current` emits if either side is renamed. → **Mitigation:** Both sides hard-code the literal `"Default"`; spec scenarios assert the exact string so a future rename would fail validation on both sides.
- **Trade-off:** A small amount of CLI-surface duplication (`--off` and `Default` mean the same thing). Accepted because the discoverability win is the whole point of the fix.
