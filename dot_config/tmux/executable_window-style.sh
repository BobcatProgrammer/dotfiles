#!/usr/bin/env bash
# Override window-status formats after TPM/tmux2k have run.
# Active window:   Catppuccin blue pill (#8aadf4 bg, #1e2030 text)
# Inactive window: Subtle grey-blue pill (#2d3248 bg, #cad3f5 text)
# Bar background:  #1e2030
#
# Nerd Font round separators generated at runtime via printf to avoid
# encoding issues when the file is saved:
#   U+E0B6 = left round cap  (3 bytes: EE 82 B6)
#   U+E0B4 = right round cap (3 bytes: EE 82 B4)

BAR_BG="#1e2030"
ACTIVE_BG="#8aadf4"
ACTIVE_FG="#1e2030"
INACTIVE_BG="#2d3248"
INACTIVE_FG="#cad3f5"

L=$(printf '\xee\x82\xb6')   # U+E0B6 round left cap
R=$(printf '\xee\x82\xb4')   # U+E0B4 round right cap

# Active: left-cap (bar->active), content, right-cap (active->bar)
tmux set-window-option -g window-status-current-format \
    "#[fg=${ACTIVE_BG},bg=${BAR_BG}]${L}#[fg=${ACTIVE_FG},bg=${ACTIVE_BG},bold] #I:#W [#{b:pane_current_path}] #[fg=${ACTIVE_BG},bg=${BAR_BG}]${R}"

# Inactive: left-cap (bar->inactive), content, right-cap (inactive->bar)
tmux set-window-option -g window-status-format \
    "#[fg=${INACTIVE_BG},bg=${BAR_BG}]${L}#[fg=${INACTIVE_FG},bg=${INACTIVE_BG}] #I:#W [#{b:pane_current_path}] #[fg=${INACTIVE_BG},bg=${BAR_BG}]${R}"

# Gap between pills (margin)
tmux set-window-option -g window-status-separator " "
