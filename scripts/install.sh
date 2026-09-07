#!/usr/bin/env sh
# BobcatProgrammer dotfiles bootstrap
#
# One-liner:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/BobcatProgrammer/dotfiles/master/scripts/install.sh)"
#
# Installs on a fresh machine/container, in order:
#   1. distro prerequisites (curl, git, …)
#   2. Nix (Determinate installer)
#   3. home-manager (into the active nix profile)
#   4. chezmoi + this repo's configs (scripts and encrypted files excluded:
#      scripts need tools installed by home-manager, encrypted files need the
#      age key from Bitwarden)
#   5. home-manager switch (builds the whole package set)
#   6. chezmoi apply again so the now-runnable scripts execute (fisher
#      plugins, gke auth plugin, tmux separators, default-shell setup)
#
# Re-runnable (idempotent). Env overrides:
#   DOTFILES_REPO   clone source: git URL or local path (default: GitHub repo)
#                   — CI and pre-push testing mount this repo and point here.

set -eu

log() {
    printf '[dotfiles] %s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"
}

die() {
    log "ERROR: $*" >&2
    exit 1
}

# --- 0. environment ---------------------------------------------------------
export HOME="${HOME:-$(getent passwd "$(id -u)" | cut -d: -f6)}"
export USER="$(id -un)"
export LOGNAME="${LOGNAME:-$USER}"

# --- 1. distro prerequisites ------------------------------------------------
need_prereqs() {
    command -v curl >/dev/null 2>&1 || return 0
    command -v git >/dev/null 2>&1 || return 0
    return 1
}

if need_prereqs; then
    if [ "$(id -u)" -ne 0 ]; then
        die "curl/git missing; re-run as root or install curl+git first"
    fi
    os_id="$(sed -n 's/^ID=//p' /etc/os-release 2>/dev/null || echo unknown)"
    case "$os_id" in
        fedora|rhel|centos)
            log "installing prereqs via dnf"
            dnf -y install curl git util-linux >/dev/null 2>&1 || die "dnf install failed"
            ;;
        debian|ubuntu)
            log "installing prereqs via apt-get"
            apt-get update -qq >/dev/null 2>&1 || die "apt-get update failed"
            apt-get install -y -qq curl git util-linux procps >/dev/null 2>&1 || die "apt-get install failed"
            ;;
        *)
            die "unsupported distro: $os_id — install curl and git, then re-run"
            ;;
    esac
fi

# --- 2. Nix (Determinate) -----------------------------------------------------
if ! command -v nix >/dev/null 2>&1; then
    log "installing Nix (Determinate installer)"
    if [ -d /run/systemd/system ]; then
        extra="--no-confirm"
    else
        log "no systemd detected; installing root-only nix (linux --init none)"
        extra="linux --init none --no-confirm"
    fi
    # shellcheck disable=SC2086
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install $extra \
        || die "Nix install failed"
fi

# Make nix available for the rest of the script
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
fi
command -v nix >/dev/null 2>&1 || die "nix not on PATH after install"

export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# --- 3. home-manager ----------------------------------------------------------
if ! command -v home-manager >/dev/null 2>&1; then
    log "installing home-manager CLI into the nix profile"
    nix profile install github:nix-community/home-manager || die "home-manager install failed"
fi

# `home-manager switch` activation installs its own home-manager-path env into
# the same profile; keeping the standalone CLI package there too conflicts
# (both provide bin/home-manager). Remember the CLI store path, drop the
# profile entry, and run the remembered binary — later switches use the env's
# home-manager from ~/.nix-profile.
HM_BIN="$(readlink -f "$(command -v home-manager)")"
if nix profile list 2>/dev/null | grep -q 'home-manager$'; then
    log "removing standalone home-manager CLI from profile (switch manages its own)"
    nix profile remove home-manager || true
fi

# --- 4. chezmoi + repo configs -------------------------------------------------
if ! command -v chezmoi >/dev/null 2>&1; then
    log "installing chezmoi"
    curl -fsSL https://get.chezmoi.io | sh -s -- -b "$HOME/.local/bin" || die "chezmoi install failed"
    export PATH="$HOME/.local/bin:$PATH"
fi

REPO="${DOTFILES_REPO:-https://github.com/BobcatProgrammer/dotfiles.git}"
SOURCE_DIR="$HOME/.local/share/chezmoi"
if [ -d "$SOURCE_DIR/.git" ]; then
    log "chezmoi source already present; pulling latest"
    git -C "$SOURCE_DIR" pull --ff-only -q || log "WARNING: pull failed; continuing with existing source"
else
    log "cloning dotfiles from $REPO"
    chezmoi init "$REPO" || die "chezmoi init failed"
fi

log "applying configs (excluding scripts and encrypted files)"
chezmoi apply --exclude=scripts,encrypted || die "chezmoi apply failed"

# --- 5. home-manager switch -----------------------------------------------------
log "building and switching home-manager generation (this takes a while)"
"$HM_BIN" switch || die "home-manager switch failed"

# --- 6. apply again so scripts run now that tools exist --------------------------
log "applying again with scripts enabled"
chezmoi apply --exclude=encrypted || die "second chezmoi apply failed"

log "done. Tools are at ~/.nix-profile/bin"
printf '%s\n' \
    "" \
    "Notes:" \
    "  - encrypted files (kube config) were skipped: run a full 'chezmoi apply' once" \
    "    your age key is available (bitwarden-cli logged in with BW_SESSION set)" \
    "  - if this is macOS: casks come from Homebrew — run 'chezmoi apply' and" \
    "    'brew bundle --file=\$HOME/.Brewfile' after installing Homebrew"
