#!/bin/bash

# Install Homebrew
function InstallHomebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

function InstallBrewfile() {
    brew bundle --file=.
}

# Install Homebrew if not found, then install packages from Brewfile
if ! command -v brew >/dev/null 2>&1; then
    InstallHomebrew
    if [ $? -eq 0 ]; then
        InstallBrewfile
    else
        echo "Failed to install Homebrew."
        exit 1
    fi
else
    InstallBrewfile
fi
