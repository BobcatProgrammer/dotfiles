
# ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██║██╔════╝██║  ██║
# █████╗  ██║███████╗███████║
# ██╔══╝  ██║╚════██║██╔══██║
# ██║     ██║███████║██║  ██║
# ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
# A smart and user-friendly command line
# https://fishshell.com

#######################################################################
#                            main settings                            #
#######################################################################

fish_add_path /usr/local/sbin
fish_add_path $HOME/bin
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /opt/homebrew/opt/ruby/bin

# set default username to hide user@host ... see agnoster theme
set DEFAULT_USER trockels

# Set tmux config path
set -Ux fish_tmux_config $HOME/.config/tmux/tmux.conf

# theme
set theme_color_scheme "catppuccin"

# Set icons as default for exa
set -Ux EXA_STANDARD_OPTIONS --icons

# disable fish greeting
set fish_greeting

# -> Starting in kubectl v1.25, this plugin will be required for authentication.
# -> https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Set k9s dir to XDG_CONFIG_HOME
export K9S_CONFIG_DIR=$HOME/.config/k9s

