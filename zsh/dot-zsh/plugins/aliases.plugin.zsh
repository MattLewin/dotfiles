# aliases.plugin.zsh

# Overwrite any existing aliases() definition deterministically
if (( $+functions[aliases] )); then
  unset -f aliases
fi

aliases() {
  # Hard requirement checks (no fallbacks)
  (( $+commands[rg] )) || { print -r -- "aliases: ripgrep (rg) not found" >&2; return 127; }
  (( $+commands[fzf-tmux] )) || { print -r -- "aliases: fzf-tmux not found" >&2; return 127; }

  local sel
  sel=$( alias | \
         rg --color=always '^[^=]+' | \
         fzf-tmux --ansi --reverse --cycle --height=90% --query="${1:-}" --multi --select-1 --exit-0 | \
         cut -d '=' -f 1 ) || return 1

  print -r -- "$sel"
}
