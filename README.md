# dotfiles
macOS and UNIX configuration files

## Installation
clone the repo and all submodules
`make`

This will install [oh-my-zsh](https://ohmyz.sh), [Homebrew](https://brew.sh), [Homebrew-file](https://homebrew-file.readthedocs.io/en/latest/index.html), and [GNU stow](https://www.gnu.org/software/stow/). It will then use `stow` to link all your dot files into your home directory.

**CAUTION**: You probably *never* want to type `make`. This entire set up is heavily customized for my usage. I've made it available so others can copy, modify, and *then* deploy it for themselves.

---
Copyright (c) Matt Lewin, No rights reserved.
