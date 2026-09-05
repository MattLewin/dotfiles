# Route pip/pipx to uv/uvx (interactive shells only)

[[ -o interactive ]] || return

# If uv isn't installed, do nothing.
(( $+commands[uv] )) || return

# --- shims ---
# Provide a friendlier `--version` for muscle-memory commands.
_pip_shim_version() {
  local _uv_ver
  _uv_ver="$(uv --version 2>/dev/null)"
  print -r -- "pip (shim) -> uv pip | ${_uv_ver:-uv}"
}

pip() {
  if [[ "$1" == "--version" || "$1" == "-V" ]]; then
    _pip_shim_version
    return 0
  fi
  uv pip "$@"
}

pip3() {
  if [[ "$1" == "--version" || "$1" == "-V" ]]; then
    _pip_shim_version
    return 0
  fi
  uv pip "$@"
}

_pipx_shim_version() {
  local _uv_ver _uvx_ver
  _uv_ver="$(uv --version 2>/dev/null)"
  _uvx_ver="$(uvx --version 2>/dev/null)"
  print -r -- "pipx (shim) -> uv tool / uvx | ${_uv_ver:-uv} | ${_uvx_ver:-uvx}"
}

pipx() {
  if [[ "$1" == "--version" || "$1" == "-V" ]]; then
    _pipx_shim_version
    return 0
  fi

  if [[ "$1" == "run" ]]; then
    shift
    uvx "$@"
  else
    uv tool "$@"
  fi
}

# --- uv/uvx completions ---
# Cache the generated completion files; regenerate only when the binary changes.
# Same cache dir as op.plugin.zsh / completions.plugin.zsh.
_uv_comp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
_uv_comp="${_uv_comp_dir}/_uv"

if [[ ! -s "$_uv_comp" || "${commands[uv]}" -nt "$_uv_comp" ]]; then
  mkdir -p "$_uv_comp_dir"
  uv generate-shell-completion zsh >| "$_uv_comp" 2>/dev/null
fi

if (( $+commands[uvx] )); then
  _uvx_comp="${_uv_comp_dir}/_uvx"
  if [[ ! -s "$_uvx_comp" || "${commands[uvx]}" -nt "$_uvx_comp" ]]; then
    mkdir -p "$_uv_comp_dir"
    uvx --generate-shell-completion zsh >| "$_uvx_comp" 2>/dev/null
  fi
fi

# compinit already ran (see .zshrc) before local plugins load, so register the
# functions explicitly to get completion in this shell, not just the next one.
fpath=("$_uv_comp_dir" $fpath)
autoload -Uz _uv && compdef _uv uv
(( $+commands[uvx] )) && { autoload -Uz _uvx && compdef _uvx uvx; }

unset _uv_comp _uvx_comp _uv_comp_dir _pip_shim_version _pipx_shim_version
