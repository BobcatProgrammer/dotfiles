#! /usr/bin/env bash
set -euo pipefail


log() {
    # macOS date doesn't support --iso-8601; fall back to a portable format
    local now
    if now=$(date --iso-8601=seconds 2>/dev/null); then
        :
    else
        now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    fi
    printf "[asdf setup]%s %s\n" "$now" "$*"
}

# Check asdf binary presence
if ! command -v asdf >/dev/null 2>&1; then
    log "asdf not found in PATH; skipping asdf plugin install (safe no-op)."
    exit 1
fi

mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
asdf completion fish > ~/.config/fish/completions/asdf.fish


# Install asdf plugins
PLUGINS=(
    "python"
    "nodejs"
    "golang"
    "php"
    "terraform"
)

for p in "${PLUGINS[@]}"; do
    if asdf plugin list | grep -q "^$p$"; then
        log "asdf plugin $p already present"
    else
        log "asdf plugin $p not found; installing"
        if ! asdf plugin add "$p" >/dev/null 2>&1; then
            log "failed to add asdf plugin $p"
            exit 1
        fi
        log "asdf plugin $p installed successfully"
    fi
done
