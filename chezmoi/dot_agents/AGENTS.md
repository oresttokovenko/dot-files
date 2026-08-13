# AGENTS.md

This machine's dotfiles are managed by [chezmoi](https://www.chezmoi.io/).
Source repo: `oresttokovenko/dot-files`, checked out at `~/.local/share/chezmoi`
(the actual source tree is the `chezmoi/` subdirectory, via `.chezmoiroot`).

## What chezmoi manages (339 files)

- `~/.zshrc` and `~/.gitconfig` — each with an intentionally untracked
  machine-local sibling (`.zshrc.local`, `.gitconfig.local`)
- `~/.config/` — nvim, pi, ghostty, starship, ripgrep, bat, btop, fastfetch,
  pypoetry, ponytail, pip
- `~/.agents/` — skills and this file
- `~/.docker/config.json`, `~/.colima/default/colima.yaml`

`chezmoi managed` lists every tracked file.

## Editing rules

- Changed a managed file? Sync it back with `chezmoi re-add <path>` (or
  `chezmoi add` for new files), then commit and push from `~/.local/share/chezmoi`.
- Machine-local overrides belong in `~/.zshrc.local` / `~/.gitconfig.local` —
  never tracked, never committed.
- `Brewfile`, `Brewfile.personal`, `Brewfile.work`, `setup.sh`, `sync.sh` live
  in the same repo but outside the chezmoi tree; commit them with plain git.
- Full workflow reference: `~/.local/share/chezmoi/CHEZMOI.md`.
