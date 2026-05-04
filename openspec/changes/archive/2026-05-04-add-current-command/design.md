## Context

`aura-cli` currently handles `--version` and `--help` flags in `main.swift` before the TUI starts. The same pre-TUI pattern can host a `current` subcommand. `ProviderStore.shared` loads providers synchronously on first access; `activeProvider` returns the active `Provider` or `nil` when the default Claude account is in use.

## Goals / Non-Goals

**Goals:**
- Add `aura-cli current` that prints the active provider as JSON to stdout
- Default state (no aura provider active) prints `{"name":"Default"}`
- Reuse existing `ProviderStore` and `Provider.Codable` — no new data layer

**Non-Goals:**
- Pretty-printed vs compact JSON is not configurable (always pretty-print for readability)
- No `--format` flag or other output options in this change
- Does not modify or activate providers

## Decisions

### Handle `current` in `main.swift` before TUI launch

Same pattern as `--version`/`--help`. Parse `CommandLine.arguments`, detect `"current"` as the first non-flag argument, call `ProviderStore.shared.load()` → read `activeProvider`, encode, print, `exit(0)`.

**Alternatives considered:**
- Dedicated `CurrentCommand.swift` service — unnecessary for a one-shot read; keeping logic in `main.swift` is consistent with existing flag handling and avoids new file proliferation.

### Encode active provider using `JSONEncoder` with `Provider` Codable conformance

`Provider` already has explicit `CodingKeys` covering all fields. Using `JSONEncoder` with `.prettyPrinted` output matches the example output shown in the proposal.

**Alternatives considered:**
- Manual string interpolation — fragile, doesn't escape special characters in token values.
- Custom `CurrentOutput` struct — overkill; `Provider`'s existing conformance already produces the correct shape.

### Default output is a minimal JSON object `{"name":"Default"}`

A dedicated struct `DefaultOutput: Codable { let name = "Default" }` keeps encoding uniform and avoids raw string printing.

## Risks / Trade-offs

- `ProviderStore.shared` does file I/O on first access; if `~/.claude/aura-providers.json` is missing, it initialises to an empty list (no crash). → Acceptable; the "Default" path is the correct output in that case.
- `ConfigImportService.syncOnStartup()` is skipped for `current` to keep the command fast and side-effect-free. → Intentional; `current` is read-only.

## Migration Plan

No migration required. Additive change only; existing TUI launch path is unchanged.
