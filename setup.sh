#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install Homebrew
InstallHomebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Install casks and formulae from Brewfile
InstallBrewfile() {
    brew bundle --file="$SCRIPT_DIR/Brewfile"
}

# Install Homebrew if not found, then install packages from Brewfile
if ! command -v brew >/dev/null 2>&1; then
    if InstallHomebrew; then
        InstallBrewfile
    else
        echo "Failed to install Homebrew"
        exit 1
    fi
else
    InstallBrewfile
fi

# Install tools not available via Homebrew
InstallAmp() {
    curl -fsSL https://ampcode.com/install.sh | bash
}

InstallPi() {
    git clone https://github.com/badlogic/pi-mono.git "$HOME/pi-mono"
    cd "$HOME/pi-mono"
    npm install
    npm run build
}

if ! command -v amp >/dev/null 2>&1; then
    echo "Installing Amp..."
    InstallAmp
fi

if [ ! -d "$HOME/pi-mono" ]; then
    echo "Installing Pi..."
    InstallPi
fi
