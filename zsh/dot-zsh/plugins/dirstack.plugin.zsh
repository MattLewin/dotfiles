# dirstack.plugin.zsh — make every `cd` push; helpers

# Classic pushd behavior; keep it quiet and dedup
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS PUSHD_TO_HOME

# Fuzzy-pick from the stack (needs fzf)
dstk() {
  (( $+commands[fzf] )) || { print -r -- "dstk: fzf not found" >&2; return 127; }
  local line idx
  line=$(dirs -v | fzf --ansi --reverse --height=50%) || return
  idx=${line%% *}
  cd ~+${idx}
}
