# dotfiles
macOS and UNIX configuration files

## Usage
Instead of cloning the repo, use this one as a template by clicking [here](https://github.com/MattLewin/dotfiles/generate), and then customize to your needs.

## Installation
clone the repo and all submodules

`make`

This will install [Antidote](https://getantidote.github.io/), [Homebrew](https://brew.sh), and [GNU stow](https://www.gnu.org/software/stow/). It will then use `stow` to link all your dot files into your home directory.

**CAUTION**: You probably *never* want to type `make`. This entire set up is heavily customized for my usage. I've made it available so others can copy, modify, and *then* deploy it for themselves.

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
