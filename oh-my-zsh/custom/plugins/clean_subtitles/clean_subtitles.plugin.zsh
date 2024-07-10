# Autocompletion for my content subtitle cleaning command
if (( ! $+commands[clean_subtitles] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `clean_subtitles`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_clean_subtitles" ]]; then
  typeset -g -A _comps
  autoload -Uz _clean_subtitles
  _comps[clean_subtitles]=_clean_subtitles
fi

clean_subtitles completion >| "$ZSH_CACHE_DIR/completions/_clean_subtitles" &|
