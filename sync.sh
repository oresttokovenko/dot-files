#!/usr/bin/env bash
# sync.sh — pull drifted config from $HOME into the chezmoi source state.
#
# `chezmoi re-add` with no arguments updates every already-managed file that
# has drifted at home. It never touches templates and never adds new files —
# both of those stay deliberate, manual acts:
#
#   chezmoi add ~/.config/some-new-tool     # start tracking something new
#   chezmoi edit ~/.zshrc                   # edit the source directly instead
#
# (Bulk auto-adding directories was tried and removed: it swept in Docker
# Desktop runtime state and overwrites intentional un-applied source edits.)
set -euo pipefail

chezmoi re-add

echo
echo "=== source changes ready to commit ==="
chezmoi git status -- --short || true
echo
echo "=== drift in apply direction (home differs from source) ==="
chezmoi status || true
