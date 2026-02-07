# dotfiles
macOS and UNIX configuration files

## Usage
Instead of cloning the repo, use this one as a template by clicking [here](https://github.com/MattLewin/dotfiles/generate), and then customize to your needs.

## Installation
clone the repo and all submodules

`make`

This will install [Antidote](https://getantidote.github.io/), [Homebrew](https://brew.sh), and [GNU stow](https://www.gnu.org/software/stow/). It will then use `stow` to link all your dot files into your home directory.

**CAUTION**: You probably *never* want to type `make`. This entire set up is heavily customized for my usage. I've made it available so others can copy, modify, and *then* deploy it for themselves.

`make` now installs Homebrew if it is missing (macOS or Linux), then proceeds with Antidote, stow, and dotfiles. On Linux/WSL, launch agents are skipped. On Linux, Homebrew prerequisites are installed via `apt-get`.

## Homebrew bundles
Split by OS for portability:

- `misc/dot-config/homebrew/Brewfile.common`
- `misc/dot-config/homebrew/Brewfile.mac`
- `misc/dot-config/homebrew/Brewfile.linux`
- `misc/dot-config/homebrew/Brewfile` (shim)

Recommended: set `HOMEBREW_BUNDLE_FILE` so `brew bundle` works anywhere (already wired in shells).

Example:

`brew bundle`

Auto-selects OS via shim at:

`~/.config/homebrew/Brewfile`

Manual:

`brew bundle --file misc/dot-config/homebrew/Brewfile.common`
`brew bundle --file misc/dot-config/homebrew/Brewfile.mac`
`brew bundle --file misc/dot-config/homebrew/Brewfile.linux`

Example (auto-selects OS when run in that directory):

`cd misc/dot-config/homebrew && brew bundle`


For system packages on Ubuntu/WSL, see:

`misc/dot-config/homebrew/apt.txt`

## Local overrides (portable setup)
To keep this portable across machines/users, put user-specific settings in local files that are not tracked:

- `~/.config/dotfiles/local.zsh` (zsh overrides)
- `~/.config/dotfiles/local.fish` (fish overrides)
- `~/.gitconfig.local` (git identity, per-user settings)

Create the local files from templates:

`install_scripts/bootstrap-local.sh`

Templates live at:

- `misc/dot-config/dotfiles/local.zsh.example`
- `misc/dot-config/dotfiles/local.fish.example`
- `git/dot-gitconfig.local.example`

## Health check
Quick check for required/optional tools:

`misc/scripts/dotfiles-healthcheck`

---
Copyright (c) Nobody, No rights reserved.
