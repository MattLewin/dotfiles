# completions.plugin.zsh — cache generated zsh completions for CLIs that would
# otherwise fork a subprocess on every shell startup. Each completion file is
# regenerated only when its binary changes. Same cache dir as the op/uv plugins.
#
# For tools whose *only* shell contribution is completion. Tools that also add
# aliases, hooks, or shims get their own *.plugin.zsh (op keeps its own for the
# TCC-prompt note; uv for its pip/pipx shims and second uvx binary).
#
# Add a tool: append "<cmd>:<command that prints a zsh completion script>".

[[ -o interactive ]] || return

_load_cached_completions() {
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
  local -a specs=(
    'clean_subtitles:clean_subtitles completion'
    'color2hex:color2hex completion zsh'
    'mole:mole completion zsh'
    'ngrok:ngrok completion'
    'ruff:ruff generate-shell-completion zsh'
    'ttl:ttl --completions=zsh'
  )

  fpath=("$dir" $fpath)

  local spec cmd gen dest
  for spec in $specs; do
    cmd=${spec%%:*}
    gen=${spec#*:}
    (( $+commands[$cmd] )) || continue

    dest="$dir/_$cmd"
    if [[ ! -s "$dest" || "${commands[$cmd]}" -nt "$dest" ]]; then
      mkdir -p "$dir"
      ${(z)gen} >| "$dest" 2>/dev/null
    fi

    # compinit already ran (see .zshrc) before local plugins load, so register
    # the function explicitly to get completion in this shell, not just the next.
    autoload -Uz "_$cmd" && compdef "_$cmd" "$cmd"
  done
}

_load_cached_completions
unfunction _load_cached_completions
