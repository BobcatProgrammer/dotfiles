# dotfiles

Dotfiles managed with [chezmoi](https://github.com/twpayne/chezmoi), designed to work across macOS, Debian, Ubuntu and Fedora.

```sh
# Install on a new machine
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply "BobcatProgrammer"
```

## Package management split

* **Packages and runtimes** → [home-manager](https://github.com/nix-community/home-manager) (the flake lives in `dot_config/home-manager/`, templated per-OS). This is the single package source on every OS: CLI tools, runtimes (go, node, php, terraform, uv…), and where possible GUI apps (VS Code + extensions, rectangle, insomnia).
* **Config files and encrypted state** → chezmoi (`dot_config/`, `dot_kube/*.age`, `dot_ssh/`, …).
* **Homebrew is macOS-only residual**: casks with no nixpkgs equivalent (`dot_Brewfile`). App Store purchases are installed via `mas` (installed by home-manager) through `.chezmoiscripts/darwin/run_once_after_install_mas_apps.sh.tmpl`.

New-machine flow (after the one-liner):

1. chezmoi applies configs and renders `~/.config/home-manager`.
2. Install Nix and home-manager (macOS first needs Xcode CLT: `xcode-select --install`):

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   nix profile install github:nix-community/home-manager
   ```

3. `home-manager switch` builds the full package set.

Chezmoi owns every file in `~/.config` (fish, tmux, git, alacritty, …); home-manager only installs binaries and environment — no `programs.*` modules overlap with chezmoi-managed dotfiles.

## Things I use

* [chezmoi](https://github.com/twpayne/chezmoi)
* [Nix](https://nixos.org) + [home-manager](https://github.com/nix-community/home-manager)
* [uv](https://docs.astral.sh/uv/) (python toolchains — no conda/pyenv/pipenv)
* [fish shell](https://fishshell.com) (+ fisher plugins)
* [Alacritty terminal](https://alacritty.org)
* [tmux](https://github.com/tmux/tmux)

## Scripts

- All scripts MUST be idempotent (safe to run multiple times).
- Scripts SHOULD log what they are doing.
- Scripts SHOULD NOT assume they are run from any particular directory.
- Scripts MUST be safe to run on any OS, even if they do nothing on some OSes.
