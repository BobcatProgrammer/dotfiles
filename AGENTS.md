# AGENTS.md — BobcatProgrammer dotfiles

Dotfiles managed with [chezmoi](https://github.com/twpayne/chezmoi), designed to work
across macOS and Linux (Debian/Ubuntu/Fedora incl. Asahi). Read the whole file
before editing. This file and README.md are `.chezmoiignore`d: they stay in the
repo and never get applied to target machines.

## Architecture: what lives where

Single package source on every OS: **home-manager** (Nix). Config files and
encrypted state stay in **chezmoi**. Homebrew is a small macOS-only residual.

| Concern | Location | Rule |
|---|---|---|
| Packages & runtimes | `dot_config/home-manager/` (rendered to `~/.config/home-manager`) | Add packages to `home.nix.tmpl`. This is a per-OS-templated flake. |
| Config files | `dot_config/`, `dot_gitconfig`, `dot_ssh/`, `dot_zshrc.tmpl`, … | `dot_` = dotfile at `$HOME`; `dot_config/foo` → `~/.config/foo`. Config stays here even when the tool is Nix-installed. |
| Encrypted/private | `dot_kube/encrypted_private_config.age`, `private_*` files | Never commit plaintext secrets. Age key comes from Bitwarden via `.chezmoiscripts/run_onchange_before_decrypt-private-key.sh`. |
| macOS GUI residual | `dot_Brewfile` + `darwin/` scripts | Only casks with no nixpkgs equivalent (raycast, logi-options+, podman-desktop, signal, krunkit, nerd fonts). Do NOT add CLI tools back here. |
| App Store apps | `.chezmoiscripts/darwin/run_once_after_install_mas_apps.sh.tmpl` | Installed via `mas` (a home-manager package); App Store is an OS channel, not a package manager. |

## Core rule: no double management of dotfiles

- Home-manager installs binaries and environment **only**. It must NOT enable
  `programs.fish`/`programs.tmux`/`programs.git`/… modules that write files
  chezmoi owns — chezmoi manages every file in `~/.config`.
- If a tool needs config, put the config in this repo under `dot_config/` and
  add only the package to `home.nix.tmpl`.
- Exceptions (where HM does generate files chezmoi does not own):
  `omp.nix` (oh-my-pi, Linux-only — loaded from `flake.nix.tmpl` only on Linux;
  keep it that way until oh-my-pi supports darwin) and fontconfig would be
  acceptable; there are none today.

## Package management workflow

- CLI packages and runtimes go in `home.nix.tmpl` (`cli` list = both OSes,
  `darwin` list = macOS only, gated by `lib.optionals`).
- Runtimes: single global nixpkgs pins (go, nodejs, php, terraform, …).
  Per-project versioning is a future direnv/`nix develop` story — do not
  reintroduce asdf/pyenv/tfenv/pipenv/conda.
- Python tooling is [uv](https://docs.astral.sh/uv/) (`uv` package). No
  conda/pyenv/pipenv blocks belong in shell configs.
- Apply on a machine: `chezmoi apply` then `home-manager switch`.
- `flake.nix.tmpl` builds `pkgs` via `import nixpkgs` with `allowUnfree = true`
  (terraform is BSL, vscode is unfree). `system` is `aarch64-{darwin,linux}`
  from `.chezmoi.os`; add `x86_64` branches if an Intel machine appears.
- `home.username`, `home.homeDirectory`, and username-dependent strings in
  fish/zsh configs come from chezmoi templates (`.chezmoi.username`,
  `.chezmoi.homeDir`), never hardcoded.
- nixpkgs `google-cloud-sdk` store is read-only, so `gcloud components install`
  cannot work. `.chezmoiscripts/run_after_gke_auth_plugin.sh` fetches
  `gke-gcloud-auth-plugin` from Google's component manifest instead.

## Templating and script conventions

- Files needing per-OS/machine values are Go templates: `*.tmpl` rendered by
  chezmoi. Use `{{ if eq .chezmoi.os "darwin" }}` guards for anything
  macOS-specific (paths like `/opt/homebrew`, `~/Library/…`).
- Chezmoi runs scripts in `.chezmoiscripts` on every OS unless the template
  renders them empty — always template-guard darwin-only scripts
  (`{{- if eq .chezmoi.os "darwin" -}} … {{- end -}}`) and/or check `uname`.
  Do not rely on the `darwin/` subdirectory to filter.
- All scripts MUST be idempotent (safe to run multiple times).
- Scripts SHOULD log what they are doing.
- Scripts SHOULD NOT assume they are run from any particular directory.
- Scripts MUST be safe to run on any OS, even if they do nothing on some OSes.

## Known edges (do not "fix" by accident)

- `run_onchange_before_decrypt-private-key.sh` exits 1 when `bw`/`BW_SESSION`
  is unavailable → a full script-inclusive `chezmoi apply` fails on machines
  without Bitwarden. Apply config-only with `chezmoi apply --exclude=scripts`
  there.
- `darwin/run_onchange_after_macos_defaults.sh` is plain bash with no template
  guard (osascript) — macOS-only in practice.
- After removing brew's fish formula on macOS, `chsh` still points at the brew
  path; re-run `run_onchange_after_make_fish_default_shell.sh` once (its
  content is unchanged so chezmoi won't re-trigger it by itself).
- Fish plugins (fisher/tide list) live in
  `run_onchange_after_10_fisher_install.sh` — they write into the
  chezmoi-owned fish config dir, so they are config-adjacent, not packages;
  keep them there. Drop plugins only when their tooling leaves the stack.
