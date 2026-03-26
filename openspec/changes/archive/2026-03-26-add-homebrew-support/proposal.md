## Why

aura-cli currently has no distribution mechanism, requiring users to clone the repo and build from source. Adding a Homebrew formula enables one-line installation (`brew install`) and automatic updates for macOS users — the primary audience for this tool.

## What Changes

- Add a `Brewfile`-compatible formula definition for aura-cli
- Add a GitHub Actions release workflow that builds a universal macOS binary, computes SHA256, and creates a GitHub Release with the artifact
- Create a Homebrew tap repository formula file (`Formula/aura-cli.rb`) for hosting in a personal tap (e.g., `homebrew-tap`)
- Update README with Homebrew installation instructions
- Add a `Makefile` or build script for producing the release binary locally

## Capabilities

### New Capabilities
- `homebrew-distribution`: Homebrew tap formula and release automation for distributing aura-cli as a macOS binary

### Modified Capabilities

## Impact

- Requires a public GitHub repository for the tap (e.g., `<user>/homebrew-tap`)
- Release workflow needs GitHub Actions with code-signing or ad-hoc signing for the binary
- Binary must be a universal (arm64 + x86_64) macOS executable built with `swift build -c release`
- No changes to application source code; purely build/distribution infrastructure
