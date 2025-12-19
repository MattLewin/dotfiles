# color2hex.plugin.zsh — activate completion for color2hex
# Loads only if sourced by .zshrc after compinit.

# Bail if the command is missing
(( $+commands[color2hex] )) || return 0

# Completion cache location (align with other plugins)
local _zfunc_dir="$HOME/.zfunc"
local _cs_comp="$_zfunc_dir/_color2hex"

# Ensure fpath includes our completion dir once
[[ ${fpath[(Ie)$_zfunc_dir]} -eq 0 ]] && fpath+="$_zfunc_dir"

# (Re)generate completion only if missing
if [[ ! -s "$_cs_comp" ]]; then
  mkdir -p "$_zfunc_dir"
  color2hex completion zsh >| "$_cs_comp" 2>/dev/null || true
fi

# If compinit already ran and _color2hex isn't loaded yet, refresh once
if ! typeset -f _color2hex >/dev/null; then
  autoload -Uz compinit && compinit -i
fi

unset _zfunc_dir _cs_comp
