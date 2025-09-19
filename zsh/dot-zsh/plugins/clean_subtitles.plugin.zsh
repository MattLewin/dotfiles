# clean_subtitles.plugin.zsh — activate completion for clean_subtitles
# Loads only if sourced by .zshrc after compinit.

# Bail if the command is missing
(( $+commands[clean_subtitles] )) || return 0

# Completion cache location (align with other plugins)
local _zfunc_dir="$HOME/.zfunc"
local _cs_comp="$_zfunc_dir/_clean_subtitles"

# Ensure fpath includes our completion dir once
[[ ${fpath[(Ie)$_zfunc_dir]} -eq 0 ]] && fpath+="$_zfunc_dir"

# (Re)generate completion only if missing
if [[ ! -s "$_cs_comp" ]]; then
  mkdir -p "$_zfunc_dir"
  clean_subtitles completion >| "$_cs_comp" 2>/dev/null || true
fi

# If compinit already ran and _clean_subtitles isn't loaded yet, refresh once
if ! typeset -f _clean_subtitles >/dev/null; then
  autoload -Uz compinit && compinit -i
fi

unset _zfunc_dir _cs_comp
