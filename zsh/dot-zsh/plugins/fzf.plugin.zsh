# fzf.plugin.zsh — load fzf completion + key bindings (`fzf --zsh`, fzf 0.48+)

(( $+commands[fzf] )) || return 0

# Skip if already loaded (e.g. the plugin is sourced twice)
if ! whence -f _fzf_complete >/dev/null; then
  source <(fzf --zsh)
fi
