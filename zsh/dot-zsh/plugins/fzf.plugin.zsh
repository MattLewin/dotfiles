# fzf.plugin.zsh — load fzf completion/bindings only if needed (Homebrew install)

# Only in interactive shells, and only if fzf exists
[[ -o interactive ]] || return 0
(( $+commands[fzf] )) || return 0

# Find Homebrew fzf base dir quickly
typeset _fzf_base=""
if (( $+commands[brew] )); then
  _fzf_base="$(brew --prefix fzf 2>/dev/null || true)"
fi
[[ -z "$_fzf_base" ]] && _fzf_base="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf"
# (1) Completions: only if not already loaded
if [[ -r "$_fzf_base/shell/completion.zsh" ]] && ! whence -f _fzf_complete >/dev/null; then
  source "$_fzf_base/shell/completion.zsh"
fi

# (2) Key bindings: only if the widgets aren't present yet
if [[ -r "$_fzf_base/shell/key-bindings.zsh" ]]; then
  if zle -l >/dev/null 2>&1; then
    if ! zle -l | grep -qx 'fzf-history-widget'; then
      source "$_fzf_base/shell/key-bindings.zsh"
    fi
  else
    # If ZLE isn't active yet (rare), source once; widgets will attach when ZLE loads
    source "$_fzf_base/shell/key-bindings.zsh"
  fi
fi

unset _fzf_base
