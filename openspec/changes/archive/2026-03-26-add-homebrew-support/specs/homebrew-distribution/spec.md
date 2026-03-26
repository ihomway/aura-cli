## ADDED Requirements

### Requirement: Release binary artifact
The project SHALL produce a universal macOS binary (arm64 + x86_64) on each versioned release tag via GitHub Actions, uploaded as a `.tar.gz` artifact to the corresponding GitHub Release.

#### Scenario: Tag push triggers release build
- **WHEN** a Git tag matching `v*.*.*` is pushed to the repository
- **THEN** GitHub Actions builds a universal binary with `swift build -c release --arch arm64 --arch x86_64`, packages it as `aura-cli-<version>-macos.tar.gz`, and attaches it to a GitHub Release

#### Scenario: Binary is ad-hoc signed
- **WHEN** the release binary is produced
- **THEN** it is signed with `codesign --sign -` so macOS Gatekeeper does not unconditionally block execution

#### Scenario: SHA256 is available post-release
- **WHEN** the GitHub Release artifact is uploaded
- **THEN** the workflow prints the SHA256 checksum of the tarball so the Homebrew formula can be updated

### Requirement: Homebrew tap formula
The project SHALL provide a Homebrew formula in a companion tap repository (`homebrew-tap`) that allows installation via `brew install <tap>/aura-cli`.

#### Scenario: User installs via Homebrew tap
- **WHEN** a user runs `brew tap <owner>/tap && brew install <owner>/tap/aura-cli`
- **THEN** Homebrew downloads the release tarball, verifies the SHA256, and places the `aura-cli` binary in the user's PATH

#### Scenario: Formula pins a specific release
- **WHEN** the formula is inspected
- **THEN** it references an exact GitHub Release artifact URL and its SHA256 checksum (no floating `HEAD` installs by default)

### Requirement: Installation documentation
The README SHALL include a Homebrew installation section so users can discover the install method without consulting external sources.

#### Scenario: User finds install instructions in README
- **WHEN** a user reads the project README
- **THEN** they find a "Installation" section with the exact `brew tap` and `brew install` commands needed

#### Scenario: README documents Gatekeeper workaround
- **WHEN** a user encounters a macOS Gatekeeper warning after installation
- **THEN** the README provides the `xattr -d com.apple.quarantine $(which aura-cli)` command as a workaround
