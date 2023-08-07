#!/usr/bin/env bash

# Check what system we are on
system_type=$(uname -s)

# Check if we are root
sudo -v
# Make sure we stay sudo during the script
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Install stuff when on mac
if [ "$system_type" = "Darwin" ]; then
    xcode-select --install

    # Check if Homebrew is installed, if not install Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew could not be found, installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # On linux we need extra steps
        BREW_PREFIX=$(brew --prefix)
        if [ "$system_type" = "Linux" ]; then
            eval "$("$BREW_PREFIX/bin/brew" shellenv)"
        fi
    else
        echo "Homebrew is installed, updating Homebrew"
        brew update
    fi

    brew install yadm
fi

# Install stuff when on linux
if [ "$system_type" = "Linux" ]; then
    sudo apt-get update
    sudo apt-get install -y build-essential yadm
fi

# Clone the dotfiles repo
cd "$HOME" || exit

yadm clone https://github.com/BobcatProgrammer/dotfiles.git --no-bootstrap