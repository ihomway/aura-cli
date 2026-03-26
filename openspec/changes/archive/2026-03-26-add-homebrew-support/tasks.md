## 1. Release Workflow (GitHub Actions)

- [x] 1.1 Create `.github/workflows/release.yml` triggered on `v*.*.*` tag push
- [x] 1.2 Add build step: `swift build -c release --arch arm64 --arch x86_64`
- [x] 1.3 Add ad-hoc codesign step: `codesign --sign - .build/apple/Products/Release/aura-cli`
- [x] 1.4 Package binary into `aura-cli-<version>-macos.tar.gz`
- [x] 1.5 Compute and print SHA256 of the tarball in the workflow output
- [x] 1.6 Upload tarball as a GitHub Release asset using `softprops/action-gh-release` or equivalent
- [x] 1.7 Verify the workflow runs successfully on a test tag

## 2. Homebrew Tap Formula

- [x] 2.1 Create a public `homebrew-tap` GitHub repository under the project owner's account
- [x] 2.2 Create `Formula/aura-cli.rb` with correct `url`, `sha256`, `version`, and `install` block
- [x] 2.3 Set `depends_on macos: ">= :sonoma"` (macOS 14) in the formula
- [x] 2.4 Verify `brew install --build-from-source` or `brew audit` passes locally
- [x] 2.5 Cut the first release tag (`v0.1.0`), capture the artifact URL and SHA256, and update the formula

## 3. Documentation

- [x] 3.1 Add an "Installation" section to README with `brew tap` and `brew install` commands
- [x] 3.2 Add a Gatekeeper workaround note (`xattr -d com.apple.quarantine`) to the README
- [x] 3.3 Document the manual formula-update process in a `RELEASING.md` or equivalent note for maintainers
