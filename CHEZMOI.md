# Chezmoi Multi-Context Setup

This repo is the **base layer**. It goes on every machine. It never contains work credentials, hostnames, or employer-specific values. Those live in a separate **work layer** that is managed by its own Chezmoi source.

## The Two Layers

Chezmoi has no native cross-source reconciliation. Two contexts managing the same target path will cause `apply` and `status` to flip-flop. Each target file must have exactly one owner.

The base and work contexts manage **disjoint target paths**. The only composition mechanism is optional `.local` includes: the base owns `~/.zshrc` and sources `~/.zshrc.local` if it exists; the work layer may own `~/.zshrc.local`.

| | Base layer | Work layer |
|---|---|---|
| Repo | `oresttokovenko/dot-files` | `$WORK_DOTFILES_REPO` |
| Source | `~/.local/share/chezmoi` | `~/.local/share/chezmoi-work` |
| Config | `~/.config/chezmoi/chezmoi.toml` | `~/.config/chezmoi-work/chezmoi.toml` |
| Cache | `~/.cache/chezmoi` | `~/.cache/chezmoi-work` |
| State | `~/.config/chezmoi/chezmoistate.boltdb` | `~/.config/chezmoi-work/chezmoistate.boltdb` |

**One-target-one-owner rule:** never let both contexts claim the same file or directory. In particular, do not use `exact_` directories in one context if the other context manages files inside them.

## What Goes Where

| Target | Owner | Notes |
|--------|-------|-------|
| `~/.zshrc` | Base | Shared shell config. Sources `~/.zshrc.local` if present |
| `~/.gitconfig` | Base | Shared Git settings. Includes `~/.gitconfig.local` if present |
| `~/.zshrc.local` | Work | Work PATH, aliases, VPN helpers, etc. |
| `~/.gitconfig.local` | Work | Work email, commit signing key, etc. |
| `~/.config/nvim/**` | Base | Editor configuration |
| `~/.config/amp/**` | Work | Work-specific tool configs |
| `~/.config/claude/**` | Work | Work-specific tool configs |

The base provides extension hooks; the work layer fills them. The base never references work content directly.

## Setting Up a New Machine

### Personal laptop

```bash
chezmoi init --apply oresttokovenko/dot-files
```

### Work laptop

```bash
# 1. Base layer (pull only on work machines)
chezmoi init oresttokovenko/dot-files
chezmoi apply

# 2. Work layer (the work repo must contain its own .chezmoi.toml.tmpl)
chezmoi init \
  --source ~/.local/share/chezmoi-work \
  --config-path ~/.config/chezmoi-work/chezmoi.toml \
  "$WORK_DOTFILES_REPO"
chezmoi \
  --source ~/.local/share/chezmoi-work \
  --config ~/.config/chezmoi-work/chezmoi.toml \
  apply
```

## Aliases

Add these to `~/.zshrc.local` on work machines:

```bash
alias czp='chezmoi'
alias czw='chezmoi \
  --source ~/.local/share/chezmoi-work \
  --config ~/.config/chezmoi-work/chezmoi.toml'
```

The shorter config-only alias works only when the work config explicitly sets `sourceDir`. The work repository must contain a `.chezmoi.toml.tmpl` with these defaults:

```toml
sourceDir = "{{ .chezmoi.homeDir }}/.local/share/chezmoi-work"
cacheDir = "{{ .chezmoi.homeDir }}/.cache/chezmoi-work"
persistentState = "{{ .chezmoi.homeDir }}/.config/chezmoi-work/chezmoistate.boltdb"

[git]
    autoCommit = false
    autoPush = false
```

With that config the short alias is valid:

```bash
alias czw='chezmoi --config ~/.config/chezmoi-work/chezmoi.toml'
```

## Daily Operations

### Personal machine

```bash
czp update
czp edit ~/.zshrc
czp apply
```

The base may be committed and pushed only from a personal machine.

### Work machine, base context

```bash
czp update
czp diff
czp apply
```

Do not run `czp add`, `czp edit`, `czp re-add`, or `czp git push` from the base context on a work machine.

### Work machine, work context

```bash
czw update
czw edit ~/.zshrc.local
czw apply ~/.zshrc.local
```

The work context may commit and push only to the work repository.

## Extension Hooks in the Base

- `~/.zshrc` loads `~/.zshrc.local`
- `~/.gitconfig` includes `~/.gitconfig.local`

Need more? Add an empty include hook to the base (for example, `.ssh/config.d/*`), then let the work layer drop the actual file there.

## Brewfiles

| File | Owner | Notes |
|------|-------|-------|
| `Brewfile` | Base | Shared tools and apps for every machine |
| `Brewfile.personal` | Personal | Personal-only apps |

`Brewfile.work` belongs in the work repository. It is temporarily present in the personal repository until the work repository is available.
