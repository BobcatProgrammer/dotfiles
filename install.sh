#!/usr/bin/env bash

# Check what system we are on
system_type=$(uname -s)

# Check if we are root
sudo -v
# Make sure we stay sudo during the script
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install stuff when on mac
if [ "$system_type" = "Darwin" ]; then
    xcode-select --install
fi
# Install stuff when on linux
if [ "$system_type" = "Linux" ]; then
    sudo apt-get update
    sudo apt-get install -y build-essential
fi


# Check if Homebrew is installed, if not install Homebrew
if ! command -v brew &> /dev/null
then
    echo "Homebrew could not be found, installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is installed, updating Homebrew"
    brew update
fi

# Clone dotfiles repo
git clone https://github.com/Bobcatprogrammer/dotfiles.git ~/.dotfiles
cd ~/.dotfiles || exit

# Symlink .config to ~/.config
ln -s ~/.dotfiles/.config ~/.config
# symlink bin to ~/.bin
ln -s ~/.dotfiles/bin ~/.bin


# Install Brewfile
brew bundle --file=.config/install/Brewfile
brew cleanup

# When on mac install macos defaults
if [ "$system_type" = "Darwin" ]; then
    source .config/install/macos.sh
fi