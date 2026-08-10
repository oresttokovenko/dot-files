# Chezmoi Multi-Context Setup

This repo is the **shared base layer**. It never contains work-specific credentials, hostnames, or employer references. Those live in a separate **work layer** that applies on top.

## Architecture

```
┌─────────────────────────────────────────┐
│  Work layer (squareup/personal-ot-...)  │  ← machine-specific, can push
│  Source: ~/.local/share/chezmoi-work    │
│  Config: ~/.config/chezmoi/chezmoi-work.toml
├─────────────────────────────────────────┤
│  Base layer (oresttokovenko/dot-files)  │  ← shared, pull-only on work machines
│  Source: ~/.local/share/chezmoi         │
│  Config: ~/.config/chezmoi/chezmoi.toml │
└─────────────────────────────────────────┘
                           │
                    chezmoi apply
                           │
                         $HOME
```

The base layer is applied first. The work layer is applied second, so work-specific files override or extend the base.

## Ownership Model

| File | Owned by | Notes |
|------|----------|-------|
| `~/.zshrc` | Base | Sources `~/.zshrc.local` and `~/.zshrc.work` if present |
| `~/.gitconfig` | Base | Includes `~/.gitconfig.local` if present |
| `~/.zshrc.local` | Work | Work PATH, aliases, VPN helpers, etc. |
| `~/.gitconfig.local` | Work | Work email, signing key, etc. |
| `~/.zshrc.work` | Work | Optional extra work zsh config |

**Rule:** The base layer provides extension hooks; the work layer fills them. The base never references work content directly.

## Quick Start

### Personal machine

```bash
# One context only
chezmoi init --apply oresttokovenko/dot-files
```

### Work machine

```bash
# 1. Base layer (read-only)
chezmoi init oresttokovenko/dot-files
chezmoi apply

# 2. Work layer (read-write)
chezmoi init --config ~/.config/chezmoi/chezmoi-work.toml \
  --source-path ~/.local/share/chezmoi-work \
  squareup/personal-ot-dot-files
chezmoi apply --config ~/.config/chezmoi/chezmoi-work.toml
```

## Making Changes

**Base changes** (tools, aliases, editor config that apply everywhere):

```bash
# Edit live file or source directly
nvim ~/.zshrc
# or
chezmoi edit ~/.zshrc

# Pull drift back into the repo
chezmoi re-add ~/.zshrc

# Commit and push
chezmoi git add .
chezmoi git commit -m "..."
chezmoi git push
```

**Work changes** (machine-specific overrides):

```bash
# Use the work context config
chezmoi edit --config ~/.config/chezmoi/chezmoi-work.toml ~/.zshrc.local
chezmoi apply  --config ~/.config/chezmoi/chezmoi-work.toml ~/.zshrc.local

# Commit from the work source tree
cd ~/.local/share/chezmoi-work
git add . && git commit -m "..." && git push
```

## Aliases (optional)

Add to `~/.zshrc.local` on work machines:

```bash
alias czp='chezmoi'
alias czw='chezmoi --config ~/.config/chezmoi/chezmoi-work.toml'
```

## Extension Points in the Base Layer

The base layer already includes these hooks:

- `~/.zshrc` → sources `~/.zshrc.local` and `~/.zshrc.work`
- `~/.gitconfig` → includes `~/.gitconfig.local`

If you need more hooks (e.g. `.ssh/config.d/work`, `.p10k.zsh.work`), add them to the base layer as empty/optional includes, then let the work layer populate the actual file.
