## Context

aura-cli is a macOS-only Swift CLI tool with no current distribution mechanism. Users must clone the repository and run `swift build`. The tool targets macOS 14+ and is built with Swift Package Manager. The primary distribution target is macOS users who already have Homebrew installed.

Homebrew supports two distribution models:
1. **Core formula** — submitted to `homebrew/homebrew-core` (requires significant install base)
2. **Tap** — a personal/org GitHub repository (`homebrew-<name>`) that users add with `brew tap`

## Goals / Non-Goals

**Goals:**
- Enable `brew install <tap>/aura-cli` as a single-command install path
- Automate release binary creation via GitHub Actions on version tags
- Produce a universal binary (arm64 + x86_64) for broad macOS compatibility
- Keep formula SHA256 pinned to a specific release artifact

**Non-Goals:**
- Submission to homebrew/homebrew-core (requires adoption threshold)
- Code signing with an Apple Developer certificate (ad-hoc signing is sufficient for now)
- Linux support
- Auto-updating the tap formula from the main repo CI (manual update initially)

## Decisions

### 1. Personal tap over core formula
**Decision**: Distribute via a personal tap (e.g., `<user>/homebrew-tap`), not homebrew-core.
**Rationale**: Core requires significant adoption; a tap is immediately actionable and standard practice for new CLI tools.
**Alternative**: Homebrew cask — rejected because aura-cli is a pure CLI tool, not a GUI app.

### 2. Universal binary via `swift build --arch arm64 --arch x86_64`
**Decision**: Build a universal macOS binary using Swift's multi-arch support.
**Rationale**: Eliminates Rosetta overhead on Apple Silicon; single artifact simplifies the formula.
**Alternative**: Separate arm64/x86_64 bottles — more complex formula, not worth it at this stage.

### 3. GitHub Actions release workflow triggered on `v*` tags
**Decision**: Release workflow runs on `git push --tags v*.*.*` pattern.
**Rationale**: Conventional, integrates with GitHub Releases, generates the artifact URL and SHA that the formula needs.
**Steps**: checkout → build universal binary → create tarball → upload to GitHub Release → print SHA256.

### 4. Formula hosted in a separate `homebrew-tap` repo
**Decision**: The formula lives in a separate `homebrew-tap` GitHub repository, manually updated after each release.
**Rationale**: Standard Homebrew convention; keeps the tap independent from the source repo.
**Alternative**: `homebrew-tap` as a subdirectory in this repo — non-standard, `brew tap` won't recognize it.

### 5. Ad-hoc code signing
**Decision**: Sign the binary with `codesign --sign -` (ad-hoc) in CI.
**Rationale**: Avoids requiring a paid Apple Developer account; users may need to approve on first run via System Preferences, but this is acceptable for a developer tool.
**Alternative**: No signing — Gatekeeper will block the binary on macOS 13+.

## Risks / Trade-offs

- **SHA mismatch after re-release** → Mitigation: Never overwrite a released tag; always bump version for re-releases.
- **Ad-hoc signing Gatekeeper friction** → Mitigation: Document the `xattr -d com.apple.quarantine` workaround in README; consider notarization in a follow-up.
- **Tap formula goes stale** → Mitigation: Clearly document the manual formula-update step in the release process; automate with a follow-up PR bot later.
- **Universal binary build time in CI** → Acceptable; Swift universal builds are ~2× single-arch but still fast (<5 min).

## Migration Plan

1. Create `<user>/homebrew-tap` GitHub repository with `Formula/aura-cli.rb` scaffold
2. Add `.github/workflows/release.yml` to this repo
3. Cut first versioned release tag (`v0.1.0`)
4. Capture artifact URL + SHA256 from the GitHub Release
5. Update formula with correct URL and SHA256
6. Verify `brew install <user>/tap/aura-cli` works on a clean machine
7. Update README with install instructions

Rollback: remove the tap; no changes to source code.

## Open Questions

- What GitHub username/org should the tap live under? (needed to finalize formula `url` and `tap` name)
- Should we target `v0.1.0` as the first published release or wait for a later milestone?
