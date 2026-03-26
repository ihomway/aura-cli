# aura-cli

A macOS terminal UI for managing multiple [Claude Code](https://claude.ai/code) API providers. Switch between Anthropic, third-party, and custom endpoints by toggling which provider's credentials are active in `~/.claude/settings.json`.

## Features

- **Multiple providers** — store credentials for Anthropic, Zhipu AI, z.ai, Moonshot AI, or any custom endpoint
- **One-key switching** — activate a provider from the list; settings.json is updated instantly
- **Built-in templates** — pre-filled forms for common providers
- **Duplicate token detection** — warns before saving a token already used by another provider
- **Startup sync** — reconciles settings.json with the provider list on every launch

## Requirements

- macOS 14+
- Swift 6.2+ (Xcode 16+)

## Installation

### Homebrew (recommended)

```bash
brew tap ihomway/tap
brew install ihomway/tap/aura-cli
```

If macOS Gatekeeper blocks the binary on first run, remove the quarantine flag:

```bash
xattr -d com.apple.quarantine $(which aura-cli)
```

### Build from source

```bash
git clone https://github.com/ihomway/aura-cli
cd aura-cli
swift build -c release
cp .build/release/aura-cli /usr/local/bin/aura-cli
```

## Usage

```bash
aura-cli           # launch interactive TUI
aura-cli --version
aura-cli --help
```

### TUI Controls

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate |
| `Enter` | Activate provider / confirm / next field |
| `Tab` | Next field (forms) |
| `Esc` | Back / cancel |
| `a` | Add provider |
| `e` | Edit selected provider |
| `d` | Delete selected provider |
| `q` | Quit |

## Configuration

| Path | Purpose |
|------|---------|
| `~/.claude/aura-providers.json` | Provider list (managed by aura-cli) |
| `~/.claude/settings.json` | Claude Code config (env vars written here on activation) |
| `~/.claude/settings.json.backup` | Backup created before each write |

## Built With

- [TauTUI](https://github.com/steipete/TauTUI) — terminal UI framework
