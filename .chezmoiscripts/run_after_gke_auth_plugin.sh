#!/usr/bin/env bash
set -euo pipefail

# Install/update gke-gcloud-auth-plugin (kubectl GKE auth) to ~/.local/bin.
#
# The nixpkgs google-cloud-sdk does not bundle this component and its store is
# read-only, so `gcloud components install` cannot work. Google publishes the
# binaries in its own component repo; we mirror the gcloud component manager:
# resolve the platform component from the components manifest, download the
# tarball, and install the single binary. Idempotent + self-updating: no-op
# unless the upstream build changed (tracked via a marker file).

log() {
    local now
    if now=$(date --iso-8601=seconds 2>/dev/null); then
        :
    else
        now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    fi
    printf "[gke-auth-plugin]%s %s\n" "$now" "$*"
}

DEST="$HOME/.local/bin/gke-gcloud-auth-plugin"
MARKER="$HOME/.cache/chezmoi/gke-auth-plugin-source"
MANIFEST_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json"
BASE_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/"

# jq/curl arrive with home-manager; until then this cannot run (do not fail applies)
for dep in curl jq; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        log "$dep not available yet (pre-home-manager?); skipping"
        exit 0
    fi
done

os=$(uname -s)
arch=$(uname -m)
case "$os-$arch" in
    Darwin-arm64)  component="gke-gcloud-auth-plugin-darwin-arm" ;;
    Darwin-x86_64) component="gke-gcloud-auth-plugin-darwin-x86_64" ;;
    Linux-aarch64) component="gke-gcloud-auth-plugin-linux-arm" ;;
    Linux-x86_64)  component="gke-gcloud-auth-plugin-linux-x86_64" ;;
    *)
        log "unsupported platform $os-$arch; skipping"
        exit 0
        ;;
esac

log "resolving $component from gcloud components manifest"
SOURCE=$(curl -fsSL "$MANIFEST_URL" | jq -r --arg id "$component" '.components[] | select(.id==$id) | .data.source')
if [[ -z "$SOURCE" || "$SOURCE" == "null" ]]; then
    log "component $component not found in manifest; skipping"
    exit 0
fi

if [[ -x "$DEST" ]] && [[ -f "$MARKER" ]] && [[ "$(cat "$MARKER")" == "$SOURCE" ]]; then
    log "already up to date ($(basename "$SOURCE"))"
    exit 0
fi

TMPDIR_=$(mktemp -d)
trap 'rm -rf "$TMPDIR_"' EXIT

log "downloading ${BASE_URL}${SOURCE}"
curl -fsSL -o "$TMPDIR_/plugin.tar.gz" "${BASE_URL}${SOURCE}"
tar -xzf "$TMPDIR_/plugin.tar.gz" -C "$TMPDIR_"

BIN=$(find "$TMPDIR_" -type f -name 'gke-gcloud-auth-plugin' | head -n 1)
if [[ -z "$BIN" ]]; then
    log "binary not found inside component archive; aborting"
    exit 1
fi

mkdir -p "$HOME/.local/bin" "$(dirname "$MARKER")"
install -m 0755 "$BIN" "$DEST.tmp"
mv "$DEST.tmp" "$DEST"
echo "$SOURCE" > "$MARKER"
log "installed $DEST ($(basename "$SOURCE"))"
