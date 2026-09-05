# op.plugin.zsh — cached zsh completion for the 1Password CLI
# Running `op` on every shell start trips a macOS Sequoia (TCC) prompt in the
# terminal, so generate the completion file only when the binary changes.
# Same cache dir as completions.plugin.zsh / uv.plugin.zsh.

[[ -o interactive ]] || return
(( $+commands[op] )) || return

_op_comp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
_op_comp="${_op_comp_dir}/_op"

if [[ ! -s "$_op_comp" || "${commands[op]}" -nt "$_op_comp" ]]; then
  mkdir -p "$_op_comp_dir"
  op completion zsh >| "$_op_comp" 2>/dev/null
fi

# compinit already ran (see .zshrc) before local plugins load, so register the
# function explicitly to get completion in this shell, not just the next one.
fpath=("$_op_comp_dir" $fpath)
autoload -Uz _op && compdef _op op

unset _op_comp _op_comp_dir
