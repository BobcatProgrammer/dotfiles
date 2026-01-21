
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
set HOMEBREW_PREFIX $(brew --prefix)
fish_add_path /usr/local/sbin
fish_add_path $HOME/bin
fish_add_path $HOMEBREW_PREFIX/bin
fish_add_path $HOMEBREW_PREFIX/sbin
fish_add_path $HOMEBREW_PREFIX/opt/ruby/bin
fish_add_path $HOME/Applications/Alacritty.app/Contents/MacOS
fish_add_path $HOMEBREW_PREFIX/share/google-cloud-sdk/bin

export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

# Golang environment variables
export GOROOT=$(brew --prefix go)/libexec
export GOPATH=$HOME/go
fish_add_path $GOPATH/bin
fish_add_path $GOROOT/bin
fish_add_path $HOME/.local/bin

# VSCode Terminal integration
string match -q "$TERM_PROGRAM" "vscode"
and . (code --locate-shell-integration-path fish)
# End VSCode Terminal integration

# Run tmux automatically if in an interactive shell and not already in tmux
if status is-interactive
    and not set -q TMUX
    and not set -q VSCODE_TERMINAL
    and test "$TERM_PROGRAM" != "vscode"
    and command -q tmux
            tmux attach -t main || tmux new -s main
end

# Autoload venv
function __auto_source_venv --on-variable PWD
    if test -e .venv/bin/activate.fish
        source .venv/bin/activate.fish
    end
end
set -gx PIP_REQUIRE_VIRTUALENV 1

# set default username to hide user@host ... see agnoster theme
set DEFAULT_USER trockels

# Set tmux config path
set -Ux fish_tmux_config $HOME/.config/tmux/tmux.conf

# theme
set theme_color_scheme 'Catppuccin Mocha'

# Set icons as default for exa
set -Ux EZA_STANDARD_OPTIONS --icons

# disable fish greeting
set fish_greeting

# Set k9s dir to XDG_CONFIG_HOME
export K9S_CONFIG_DIR=$HOME/.config/k9s

#Set bat theme to catppuccin
set -Ux BAT_THEME "Catppuccin-mocha"

# pnpm
set -gx PNPM_HOME "/Users/trockels/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

pyenv init - | source

# Check if zoxide is installed
if command -v zoxide > /dev/null
  zoxide init --cmd cd fish | source
end

# if bat is installed, enable its shell integration
if command -v bat > /dev/null
  bat --completion fish | source
end



# -> Starting in kubectl v1.25, this plugin will be required for authentication.
# -> https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True


# load completions for gcloud with bass
if command -v bass > /dev/null
  # get the latest version of gcloud in Caskroom
  set -x GCLOUD_VERSION $(ls -1 /opt/homebrew/Caskroom/gcloud-cli | sort -V | tail -n 1)
  bass source /opt/homebrew/Caskroom/gcloud-cli/$GCLOUD_VERSION/google-cloud-sdk/path.bash.inc
  bass source /opt/homebrew/Caskroom/gcloud-cli/$GCLOUD_VERSION/google-cloud-sdk/completion.bash.inc
  bass export CLOUDSDK_PYTHON_SITEPACKAGES=1

  # Initialize ssh-agent with Bitwarden
  # Check if socket exists in ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock 
  if test -S ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
    bass $(ssh-agent -k -a ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock)
    set -xg SSH_AUTH_SOCK ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
  end


end



# krew
set -gx PATH $PATH $HOME/.krew/bin



direnv hook fish | source


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
    eval /opt/homebrew/Caskroom/miniconda/base/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/homebrew/Caskroom/miniconda/base/etc/fish/conf.d/conda.fish"
        . "/opt/homebrew/Caskroom/miniconda/base/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/homebrew/Caskroom/miniconda/base/bin" $PATH
    end
end
# <<< conda initialize <<<

