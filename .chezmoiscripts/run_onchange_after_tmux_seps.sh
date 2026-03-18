#!/usr/bin/env bash
# Generates ~/.config/tmux/seps.conf with Nerd Font arrow glyphs for tmux2k.
#
# The file contains literal UTF-8 bytes (U+E0B0, U+E0B2) which cannot be
# stored safely in a plain text file in the repo. This script regenerates it
# at apply time using python3 so it works on any new system.
#
#   U+E0B0 = filled arrow pointing right (EE 82 B0) — tmux2k left separator
#   U+E0B2 = filled arrow pointing left  (EE 82 B2) — tmux2k right separator

set -euo pipefail

mkdir -p ~/.config/tmux

python3 -c "
import sys
sys.stdout.buffer.write(
    b'set -g @tmux2k-left-sep \"\xee\x82\xb0\"\n'
    b'set -g @tmux2k-right-sep \"\xee\x82\xb2\"\n'
)
" > ~/.config/tmux/seps.conf
