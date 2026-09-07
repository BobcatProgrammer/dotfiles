# dotfiles

Dotfiles managed with [chezmoi](https://github.com/twpayne/chezmoi), designed to work across macOS, Fedora, Debian and Ubuntu.

## Fresh machine, one line

Installs Nix (Determinate), home-manager, chezmoi, applies all configs, and builds the full package set:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BobcatProgrammer/dotfiles/master/scripts/install.sh)"
```

Verified green from scratch inside `fedora:latest` and `debian:latest` containers (`scripts/verify.sh` asserts the tools, configs, PTY launches and Nerd Font; GitHub Actions runs the same checks — see `.github/workflows/verify.yml`). For local/pre-push testing point the repo at a checkout: `DOTFILES_REPO=/path/to/repo`.

## Package management split

* **Packages and runtimes** → [home-manager](https://github.com/nix-community/home-manager) (the flake lives in `dot_config/home-manager/`, templated per-OS). This is the single package source on every OS: CLI tools, runtimes (go, node, php, terraform, uv…), the terminal stack (fish, tmux, zellij, lazygit, neovim, omp), and where possible GUI apps (VS Code + extensions, rectangle, insomnia). Linux also gets the Hack Nerd Font (macOS keeps the brew casks).
* **Config files and encrypted state** → chezmoi (`dot_config/`, `dot_kube/*.age`, `dot_ssh/`, …).
* **Homebrew is macOS-only residual**: casks with no nixpkgs equivalent (`dot_Brewfile`). App Store purchases are installed via `mas` (installed by home-manager) through `.chezmoiscripts/darwin/run_once_after_install_mas_apps.sh.tmpl`.

Chezmoi owns every file in `~/.config` (fish, tmux, zellij, lazygit, nvim, alacritty, …); home-manager only installs binaries and environment — no `programs.*` modules overlap with chezmoi-managed dotfiles.

## Things I use

* [chezmoi](https://github.com/twpayne/chezmoi)
* [Nix](https://nixos.org) + [home-manager](https://github.com/nix-community/home-manager)
* [omp (oh-my-pi)](https://github.com/can1357/oh-my-pi) prompt
* [fish shell](https://fishshell.com) (+ fisher plugins)
* [neovim](https://neovim.io) · [lazygit](https://github.com/jesseduffield/lazygit) · [zellij](https://zellij.dev) · [tmux](https://github.com/tmux/tmux)
* [Alacritty terminal](https://alacritty.org)
* [uv](https://docs.astral.sh/uv/) (python toolchains — no conda/pyenv/pipenv)

## Scripts

- All scripts MUST be idempotent (safe to run multiple times).
- Scripts SHOULD log what they are doing.
- Scripts SHOULD NOT assume they are run from any particular directory.
- Scripts MUST be safe to run on any OS, even if they do nothing on some OSes.
