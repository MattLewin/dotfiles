# dotfiles
macOS and UNIX configuration files

## Usage
Instead of cloning the repo, use this one as a template by clicking [here](https://github.com/MattLewin/dotfiles/generate), and then customize to your needs.

## Installation
clone the repo and all submodules

`make`

This will install [Antidote](https://getantidote.github.io/), [Homebrew](https://brew.sh), and [GNU stow](https://www.gnu.org/software/stow/). It will then use `stow` to link all your dot files into your home directory.

**CAUTION**: You probably *never* want to type `make`. This entire set up is heavily customized for my usage. I've made it available so others can copy, modify, and *then* deploy it for themselves.

---
Copyright (c) Nobody, No rights reserved.
