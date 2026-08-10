# How This Dotfiles Setup Works

This repo is the **base layer**. It goes on every machine. It never contains work credentials, hostnames, or employer names. That lives in a separate **work layer** that applies on top.

## The Two Layers

Think of it like CSS: base loads first, then work overrides or adds what it needs.

| | Base layer | Work layer |
|---|---|---|
| Repo | `oresttokovenko/dot-files` | `your-work-repo` |
| Source path | `~/.local/share/chezmoi` | `~/.local/share/chezmoi-work` |
| Config | `~/.config/chezmoi/chezmoi.toml` | `~/.config/chezmoi/chezmoi-work.toml` |
| On work machines | pull only | pull + push |

The base never references work stuff. It leaves **hooks**: empty extension points the work layer fills in.

## What Goes Where

| File | Owner | Notes |
|------|-------|-------|
| `~/.zshrc` | Base | Shared shell config. Sources `~/.zshrc.local` and `~/.zshrc.work` if present |
| `~/.gitconfig` | Base | Shared Git settings. Includes `~/.gitconfig.local` if it exists |
| `~/.zshrc.local` | Work | Work PATH tweaks, VPN aliases, etc. |
| `~/.gitconfig.local` | Work | Work email, commit signing key, etc. |

The rule: base provides the hooks, work fills them. Never the other way around.

## Brewfiles

The same model applies to Homebrew:

| File | Owner | Notes |
|------|-------|-------|
| `Brewfile` | Base | Shared tools and apps for every machine |
| `Brewfile.personal` | Personal | Personal-only apps (Plex, 1Password, etc.) |
| `Brewfile.work` | Work | Work-only tools (database IDEs, Snowflake CLI, etc.) |

On a personal machine: `brew bundle` then `brew bundle --file=Brewfile.personal`
On a work machine: `brew bundle` then `brew bundle --file=Brewfile.work`

## Setting Up a New Machine

### Personal laptop

```bash
chezmoi init --apply oresttokovenko/dot-files
```

That's it.

### Work laptop

```bash
# Base layer (read-only)
chezmoi init oresttokovenko/dot-files
chezmoi apply

# Work layer (read-write)
chezmoi init --config ~/.config/chezmoi/chezmoi-work.toml \
  --source-path ~/.local/share/chezmoi-work \
  your-work-repo
chezmoi apply --config ~/.config/chezmoi/chezmoi-work.toml
```

## Making Changes

### Editing shared stuff (base layer)

```bash
# Option 1: edit the live file, then pull it back
nvim ~/.zshrc
chezmoi re-add ~/.zshrc

# Option 2: edit the source directly
chezmoi edit ~/.zshrc

# Either way, commit from chezmoi's source tree
chezmoi git add .
chezmoi git commit -m "..."
chezmoi git push
```

### Editing work-only stuff (work layer)

```bash
# Edit through the work context
chezmoi edit --config ~/.config/chezmoi/chezmoi-work.toml ~/.zshrc.local
chezmoi apply --config ~/.config/chezmoi/chezmoi-work.toml ~/.zshrc.local

# Commit from the work source tree
cd ~/.local/share/chezmoi-work
git add . && git commit -m "..." && git push
```

## Aliases

Add these to `~/.zshrc.local` on work machines:

```bash
alias czp='chezmoi'
alias czw='chezmoi --config ~/.config/chezmoi/chezmoi-work.toml'
```

## Extension Hooks Already in the Base

- `~/.zshrc` loads `~/.zshrc.local` and `~/.zshrc.work`
- `~/.gitconfig` loads `~/.gitconfig.local`

Need more? Add an empty include to the base (e.g. `.ssh/config.d/*`), then let the work layer drop the actual file there.
