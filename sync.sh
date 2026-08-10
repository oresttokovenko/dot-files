#!/usr/bin/env bash
# sync.sh — pull drifted config from $HOME into this repository's chezmoi source state.
#
# `chezmoi re-add` with no arguments updates every already-managed file that
# has drifted at home. It never touches templates and never adds new files.
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

chezmoi --source "$repo_dir" re-add

echo
echo "=== source changes ready to commit ==="
chezmoi --source "$repo_dir" git status -- --short || true
echo
echo "=== drift in apply direction (home differs from source) ==="
chezmoi --source "$repo_dir" status || true
