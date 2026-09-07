#!/usr/bin/env bash
set -euo pipefail

# Idempotent fisher + plugins installer for fish-shell
# - Safe to run multiple times
# - No-op when fish is not installed
# - Logs actions with timestamps

log() {
	# macOS date doesn't support --iso-8601; fall back to a portable format
	local now
	if now=$(date --iso-8601=seconds 2>/dev/null); then
		:
	else
		now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
	fi
	printf "%s %s\n" "$now" "$*"
}

if ! command -v fish >/dev/null 2>&1; then
	log "fish not found in PATH; skipping fisher install (safe no-op)."
	exit 0
fi

PLUGINS=(
	'jorgebucaran/fisher'
	'ilancosman/tide@v6'
	'catppuccin/fish'
	'budimanjojo/tmux.fish'
	'plttn/fish-eza'
	'patrickf1/fzf.fish'
	'z11i/github-copilot-cli.fish'
	'aysonwallach/fish-you-should-use'
	'givensuman/fish-bat'
)

if ! command -v curl >/dev/null 2>&1; then
	log "curl not found; skipping fisher install (safe no-op)."
	exit 0
fi

# Helper: detect whether fisher (the function) is available in fish
fisher_present() {
	fish -c 'if functions -q fisher; echo yes; end' 2>/dev/null | grep -q '^yes$'
}

if fisher_present; then
	log "fisher already present"
else
	log "fisher not found; installing via the upstream installer"
	# The installer is defined by sourcing the install script inside fish.
	if ! fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher' >/dev/null 2>&1; then
		log "WARNING: failed to run fisher installer (network?); skipping — rerun chezmoi apply later"
		exit 0
	fi
	# Verify again
	if fisher_present; then
		log "fisher installed successfully"
	else
		log "WARNING: fisher installation did not produce a fisher function; skipping"
		exit 0
	fi
fi

# Build plugin argument string
plugins_str=""
for p in "${PLUGINS[@]}"; do
	# Fisher expects plugins as separate args; keep them space-separated
	plugins_str+="$p "
done

if [ -z "${plugins_str// /}" ]; then
	log "no plugins defined; nothing to do"
	exit 0
fi

log "installing/updating plugins: ${PLUGINS[*]}"
# fisher install is idempotent: missing plugins are added. Network blips must
# not fail the whole chezmoi apply — log and continue; next apply retries.
if ! fish -c "fisher install $plugins_str"; then
	log "WARNING: fisher plugin install failed (network?); skipping — rerun chezmoi apply later"
	exit 0
fi

log "all plugins ensured"


fish -c "tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, character' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes" || log "WARNING: tide configure failed (non-fatal)"

