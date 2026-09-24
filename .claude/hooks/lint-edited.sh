#!/bin/sh
# PostToolUse hook: run the `make lint` check that matches the file Claude just
# edited. Exit 2 sends the lint output back to Claude. Missing tools skip.

f=$(jq -r '.tool_input.file_path // empty')
[ -f "$f" ] || exit 0

# Resolve symlinks so edits made through ~/.claude or ~/.config map into the repo.
f=$(realpath "$f")
root=$(realpath "${CLAUDE_PROJECT_DIR:-.}")
case "$f" in
  "$root"/*) rel=${f#"$root"/} ;;
  *) exit 0 ;;
esac

have() { command -v "$1" >/dev/null 2>&1; }
fail() {
  printf '%s\n' "$1" >&2
  exit 2
}

cd "$root" || exit 0

# Keep the zsh and bash lists in step with ZSH_FILES and BASH_SCRIPTS in the Makefile.
case "$rel" in
  zsh/dot-zshenv | zsh/dot-zshrc | zsh/dot-zprofile | zsh/dot-zlogin | zsh/dot-zsh/systeminfo.sh | \
    install_scripts/install-launch-agents.sh | misc/scripts/dnd_enabled | *.zsh)
    out=$(zsh -n "$rel" 2>&1) || fail "$out"
    ;;
  bash/dot-bashrc | bash/dot-bash_profile)
    have shellcheck && { out=$(shellcheck -e SC1091 -s bash "$rel" 2>&1) || fail "$out"; }
    have shfmt && { out=$(shfmt -d -ln bash -i 2 -ci "$rel" 2>&1) || fail "$out"; }
    ;;
  *.sh | misc/scripts/dotfiles-healthcheck)
    have shellcheck && { out=$(shellcheck -e SC1091 "$rel" 2>&1) || fail "$out"; }
    have shfmt && { out=$(shfmt -d -i 2 -ci "$rel" 2>&1) || fail "$out"; }
    ;;
  *.fish)
    have fish && { out=$(fish -n "$rel" 2>&1) || fail "$out"; }
    ;;
  *.json)
    out=$(jq -e . "$rel" 2>&1 >/dev/null) || fail "$out"
    ;;
  *.plist)
    have plutil && { out=$(plutil -lint "$rel" 2>&1) || fail "$out"; }
    ;;
  *.md)
    have markdownlint-cli2 && { out=$(markdownlint-cli2 "$rel" 2>&1) || fail "$out"; }
    ;;
esac
exit 0
