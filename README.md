# dot-files

Personal dotfiles managed with [Chezmoi](https://www.chezmoi.io/).

## Bootstrap

```bash
chezmoi init --apply oresttokovenko/dot-files
```

## Package Setup

```bash
bash setup.sh      # Homebrew, packages, and tools
bash macos.sh      # macOS defaults
```

## Structure

- `chezmoi/` — Chezmoi source state (the `.chezmoiroot` selects this directory)
- `Brewfile` — shared Homebrew packages for all machines
- `Brewfile.personal` — personal-only packages
- `setup.sh` — initial machine setup
- `sync.sh` — pull drifted config from `$HOME` back into the source state
- `CHEZMOI.md` — how the two-layer Chezmoi setup works

See [CHEZMOI.md](./CHEZMOI.md) for details on the personal base + work layer model.
