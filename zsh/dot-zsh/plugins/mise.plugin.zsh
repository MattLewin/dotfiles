# mise.plugin.zsh — activate mise and cache completions
# Loads only if sourced by .zshrc after compinit.

# Bail if mise is missing (defensive; .zshrc checks already)
(( $+commands[mise] )) || return 0

# Activate mise (PATH, shims, hooks)
eval "$(mise activate zsh)"

# Cached completions for mise (regen only if missing or version changed)
local _zfunc_dir="$HOME/.zfunc"
local _mise_comp="$_zfunc_dir/_mise"
local _mise_ver_file="$_zfunc_dir/_mise.version"

# Ensure fpath includes our completion dir once
[[ ${fpath[(Ie)$_zfunc_dir]} -eq 0 ]] && fpath+="$_zfunc_dir"

# If compinit already ran and _mise isn't loaded yet, refresh once
if ! typeset -f _mise >/dev/null; then
  autoload -Uz compinit && compinit -i
fi

# Determine current mise version
local _mise_ver; _mise_ver="$(mise --version 2>/dev/null)"

# (Re)generate completion if needed
if [[ ! -s "$_mise_comp" || "$_mise_ver" != "$(cat "$_mise_ver_file" 2>/dev/null)" ]]; then
  mkdir -p "$_zfunc_dir"
  mise completion zsh >| "$_mise_comp" 2>/dev/null
  print -r -- "$_mise_ver" >| "$_mise_ver_file"
fi

unset _mise_ver _zfunc_dir _mise_comp _mise_ver_file
