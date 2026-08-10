# How This Dotfiles Setup Works

This repo is the **base layer** — the stuff that goes on every machine. It doesn't know anything about your work. No work emails, no VPN configs, no employer names. That all lives in a separate **work layer** that layers on top.

## The Two Layers

Think of it like CSS: the base layer loads first, then the work layer overrides or adds what it needs.

| | Base layer | Work layer |
|---|---|---|
| Repo | `oresttokovenko/dot-files` | `squareup/personal-ot-dot-files` |
| Lives at | `~/.local/share/chezmoi` | `~/.local/share/chezmoi-work` |
| Config | `~/.config/chezmoi/chezmoi.toml` | `~/.config/chezmoi/chezmoi-work.toml` |
| On work machines | pull only | pull + push |

The base never references work stuff. Instead, it leaves **hooks** — empty extension points the work layer can fill in.

## What Goes Where

| File | Owner | Why |
|------|-------|-----|
| `~/.zshrc` | Base | Shared shell config. Sources `~/.zshrc.local` and `~/.zshrc.work` if they exist |
| `~/.gitconfig` | Base | Shared Git settings. Includes `~/.gitconfig.local` if it exists |
| `~/.zshrc.local` | Work | Work PATH tweaks, VPN aliases, etc. |
| `~/.gitconfig.local` | Work | Work email, commit signing key, etc. |

**The rule:** base provides the hooks, work fills them. Never the other way around.

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

# Work layer (your own repo)
chezmoi init --config ~/.config/chezmoi/chezmoi-work.toml \
  --source-path ~/.local/share/chezmoi-work \
  squareup/personal-ot-dot-files
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

## Optional Aliases

Add these to `~/.zshrc.local` on work machines so you don't have to type `--config` every time:

```bash
alias czp='chezmoi'
alias czw='chezmoi --config ~/.config/chezmoi/chezmoi-work.toml'
```

## Extension Hooks Already in the Base

- `~/.zshrc` → loads `~/.zshrc.local` and `~/.zshrc.work`
- `~/.gitconfig` → loads `~/.gitconfig.local`

Need more? Add an empty include to the base (e.g. `.ssh/config.d/*`), then let the work layer drop the actual file there.
