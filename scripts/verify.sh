#!/usr/bin/env bash
# Verify a fresh install (used by CI containers and after scripts/install.sh).
# Exits non-zero on the first failed check.
#
# Checks:
#   1. omp, neovim, lazygit, zellij, tmux, fish resolve on PATH, version/help exits 0
#   2. configs from the repo landed at ~/.config (chezmoi applied)
#   3. tmux and zellij start on a PTY; omp binary runs
#   4. a Nerd Font is registered with fontconfig

set -uo pipefail

fails=0
check() { # name, condition...
    local name="$1"
    shift
    local out
    if out="$("$@" 2>&1)"; then
        printf 'ok   %s\n' "$name"
    else
        printf 'FAIL %s\n' "$name"
        printf '     %s\n' "$(printf '%s' "$out" | tail -3 | tr '\n' ' ')"
        fails=$((fails + 1))
    fi
}

# Tools must be on PATH regardless of shell init
export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH"

# --- 1. tools ---------------------------------------------------------------
# Root (CI containers) makes VS Code's launcher refuse to start unless BOTH
# --no-sandbox and --user-data-dir are given.
code_flags=(--no-sandbox --user-data-dir "${TMPDIR:-/tmp}/vscode-verify")
declare -A vflag=([tmux]="-V" [code]="${code_flags[*]} --version")
for tool in omp nvim lazygit zellij tmux fish code; do
    if command -v "$tool" >/dev/null 2>&1; then
        read -r -a flags <<<"${vflag[$tool]:---version}"
        check "$tool version exits 0" "$tool" "${flags[@]}"
    else
        printf 'FAIL %s on PATH\n' "$tool"
        fails=$((fails + 1))
    fi
done

# vscode must carry the extension set from home.nix
if command -v code >/dev/null 2>&1; then
    exts="$(code "${code_flags[@]}" --list-extensions 2>/dev/null || true)"
    missing=""
    for e in golang.go hashicorp.terraform github.copilot; do
        printf '%s\n' "$exts" | grep -qx "$e" || missing="$missing $e"
    done
    if [ -z "$missing" ]; then
        printf 'ok   %s\n' "vscode extensions installed"
    else
        printf 'FAIL vscode extensions installed (missing:%s)\n' "$missing"
        fails=$((fails + 1))
    fi
fi

# --- 2. configs ---------------------------------------------------------------
for cfg in \
    .config/fish/config.fish \
    .config/zellij/config.kdl \
    .config/tmux/tmux.conf \
    .config/lazygit/config.yml \
    .config/nvim/init.lua \
    .config/home-manager/flake.nix; do
    check "config present: $cfg" test -f "$HOME/$cfg"
done

# rendered home-manager config must target linux
check "home-manager targets linux" grep -q 'x86_64-linux\|aarch64-linux' "$HOME/.config/home-manager/flake.nix"

# --- 3. PTY launches -----------------------------------------------------------
if command -v script >/dev/null 2>&1; then
    check "tmux starts a session" bash -c 'tmux -L smoke new-session -d -s s && tmux -L smoke kill-session -t s'
    # zellij: start on a PTY, let it run 5s (timeout 124 = stayed up).
    # Unique session name per run; zellij's server persists after the client
    # is killed, so clean up the session to keep reruns green.
    check "zellij runs on a PTY" bash -c 's="smoke-$$"; timeout 5 script -qec "zellij -s $s" /dev/null >/dev/null 2>&1; rc=$?; zellij kill-session "$s" >/dev/null 2>&1 || true; test "$rc" -eq 124'
    # omp: rendering the prompt for fish requires a PTY; 124 = stayed up
    if command -v omp >/dev/null 2>&1 && omp --help 2>&1 | grep -qi 'run\|shell'; then
        check "omp runs on a PTY" bash -c 'timeout 5 script -qec "omp run fish" /dev/null >/dev/null 2>&1; test $? -eq 124'
    fi
else
    printf 'skip PTY checks (no script(1))\n'
fi

# --- 4. Nerd Font --------------------------------------------------------------
if command -v fc-list >/dev/null 2>&1; then
    check "Nerd Font registered" bash -c 'fc-list | grep -qi "hack.*nerd.*font\|nerd.*font.*hack"'
else
    printf 'FAIL fc-list missing\n'
    fails=$((fails + 1))
fi

printf '\n%s\n' "$fails failing check(s)"
exit "$fails"
