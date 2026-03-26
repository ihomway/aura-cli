# Releasing aura-cli

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- Write access to [ihomway/homebrew-tap](https://github.com/ihomway/homebrew-tap)

## Steps

### 1. Bump version and tag

```bash
# Replace X.Y.Z with the new version
VERSION=X.Y.Z
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"
```

### 2. Watch the release workflow

GitHub Actions will automatically:
- Build a universal macOS binary (`arm64` + `x86_64`)
- Ad-hoc sign it
- Package it as `aura-cli-vX.Y.Z-macos.tar.gz`
- Upload it to the GitHub Release
- Print the SHA256 in the workflow log

Go to [Actions → Release](https://github.com/ihomway/aura-cli/actions) and wait for the run to complete.

### 3. Capture the artifact URL and SHA256

From the workflow log, copy:
- The artifact URL (e.g. `https://github.com/ihomway/aura-cli/releases/download/vX.Y.Z/aura-cli-vX.Y.Z-macos.tar.gz`)
- The SHA256 hash printed in the `Compute SHA256` step

### 4. Update the Homebrew formula

```bash
cd /tmp
git clone https://github.com/ihomway/homebrew-tap.git
cd homebrew-tap
```

Edit `Formula/aura-cli.rb` — update these two lines:

```ruby
url "https://github.com/ihomway/aura-cli/releases/download/vX.Y.Z/aura-cli-vX.Y.Z-macos.tar.gz"
sha256 "THE_SHA256_FROM_THE_WORKFLOW_LOG"
version "X.Y.Z"
```

Commit and push:

```bash
git add Formula/aura-cli.rb
git commit -m "Update aura-cli to vX.Y.Z"
git push
```

### 5. Verify the tap install

On a machine that doesn't already have the binary:

```bash
brew tap ihomway/tap
brew install ihomway/tap/aura-cli
aura-cli --version
```

Or update an existing install:

```bash
brew update
brew upgrade ihomway/tap/aura-cli
```

## Rollback

If a release needs to be pulled:
1. Delete the GitHub Release and tag via `gh release delete vX.Y.Z` and `git push --delete origin vX.Y.Z`
2. Revert the formula commit in `homebrew-tap` to the previous version
