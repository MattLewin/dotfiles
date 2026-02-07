#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
DOTFILES_DIR="$XDG_CONFIG_HOME/dotfiles"

mkdir -p "$DOTFILES_DIR"

copy_if_missing() {
  src=$1
  dest=$2
  if [ -e "$dest" ]; then
    printf 'exists: %s\n' "$dest"
  else
    cp "$src" "$dest"
    printf 'created: %s\n' "$dest"
  fi
}

copy_if_missing "$REPO_ROOT/misc/dot-config/dotfiles/local.zsh.example" "$DOTFILES_DIR/local.zsh"
copy_if_missing "$REPO_ROOT/misc/dot-config/dotfiles/local.fish.example" "$DOTFILES_DIR/local.fish"
copy_if_missing "$REPO_ROOT/git/dot-gitconfig.local.example" "$HOME/.gitconfig.local"
