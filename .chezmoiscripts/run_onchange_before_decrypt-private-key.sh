#!/usr/bin/env bash
set -euo pipefail

# ensure bw is installed
if ! command -v bw >/dev/null 2>&1; then
    echo "bitwarden-cli (bw) not found in PATH; cannot retrieve chezmoi age.key"
    exit 1
fi
# ensure bw is logged in
if ! bw sync >/dev/null 2>&1; then
    echo "bitwarden-cli (bw) cannot sync; are you logged in?"
    exit 1
fi
# ensure bw session is available
if [ -z "${BW_SESSION:-}" ]; then
    echo "bitwarden-cli (bw) session not found; please log in and export BW_SESSION"
    exit 1
fi

if [ ! -f "${HOME}/.config/chezmoi/age.key" ]; then
    mkdir -p "${HOME}/.config/chezmoi"
    # get the item  "Chezmoi age.key" from bitwarden and write the attached age.key file to ~/.config/chezmoi/age.key
    bw get attachment "age.key" --itemid "$(bw get item "chezmoi age.key" | jq -r '.id')" --output "${HOME}/.config/chezmoi/age.key"
    chmod 600 "${HOME}/.config/chezmoi/age.key"
fi
