#!/usr/bin/env bash
set -euo pipefail

# Check if fish is installed
if ! command -v fish >/dev/null 2>&1; then
    echo "fish shell is not installed. Skipping changing default shell."
    exit 1
fi
# Get the path to the fish binary
FISH_PATH=$(command -v fish)
if [ -z "$FISH_PATH" ]; then
    echo "Could not determine the path to the fish binary."
    exit 1
fi  
# Check if fish is already the default shell
if [ "$SHELL" == "$FISH_PATH" ]; then
    echo "fish is already the default shell."
    exit 0
fi  
# Check if fish is in /etc/shells
if ! grep -q "^$FISH_PATH$" /etc/shells; then   
    echo "Adding $FISH_PATH to /etc/shells"
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
# Change the default shell to fish
echo "Changing default shell to fish ($FISH_PATH)"
chsh -s "$FISH_PATH"
echo "Default shell changed to fish. Please restart your terminal session." 
exit 0
