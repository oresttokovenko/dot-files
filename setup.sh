#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install Homebrew
InstallHomebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Install casks and formulae from the base Brewfile (shared across all machines).
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

# perlbrew: perl version manager. Installs to ~/perl5/perlbrew (not on PATH —
# dot_zshrc sources its etc/bashrc). The installer needs a system perl to run.
InstallPerlbrew() {
    \curl -fsSL https://install.perlbrew.pl | bash
    "$HOME/perl5/perlbrew/bin/perlbrew" init
}

InstallSdkman() {
    # The installer needs Bash 4+, which macOS's system Bash (3.2) predates;
    # Homebrew's Bash is installed above, so prefer it when present.
    curl -fsSL "https://get.sdkman.io" -o /tmp/sdkman-install.sh
    if [ -x "$(brew --prefix)/bin/bash" ]; then
        "$(brew --prefix)/bin/bash" /tmp/sdkman-install.sh
    else
        bash /tmp/sdkman-install.sh
    fi
}

InstallPi() {
    git clone https://github.com/badlogic/pi-mono.git "$HOME/pi-mono"
    cd "$HOME/pi-mono"
    npm install
    npm run build
}

InstallObsidianWiki() {
    uv tool install obsidian-wiki
    # --vault scaffolds the vault when it is missing and skips the vault prompt.
    # The only remaining prompt is GitHub sync, which is skipped when stdin is
    # not a TTY; pass --remote <url> to answer it non-interactively.
    obsidian-wiki setup --vault "$HOME/Development/wiki"
}

if ! command -v amp >/dev/null 2>&1; then
    echo "Installing Amp..."
    InstallAmp
fi

if [ ! -d "$HOME/.sdkman/bin" ]; then
    echo "Installing SDKMAN!..."
    InstallSdkman
fi

if [ ! -x "$HOME/perl5/perlbrew/bin/perlbrew" ]; then
    echo "Installing perlbrew..."
    InstallPerlbrew
fi

# Pi extensions (tool guards) use npm deps via a package.json next to the
# extension files; node_modules is not synced by chezmoi, so install here.
if [ -d "$HOME/.config/pi/agent/extensions" ]; then
    echo "Installing pi extension dependencies..."
    (cd "$HOME/.config/pi/agent/extensions" && npm install --no-fund --no-audit --silent)
fi

if [ ! -d "$HOME/pi-mono" ]; then
    echo "Installing Pi..."
    InstallPi
fi

if ! command -v obsidian-wiki >/dev/null 2>&1; then
    echo "Installing obsidian-wiki..."
    InstallObsidianWiki
fi
