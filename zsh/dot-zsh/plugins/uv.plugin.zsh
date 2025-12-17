# Route pip/pipx to uv/uvx (interactive shells only)

[[ -o interactive ]] || return

# If uv isn't installed, do nothing.
(( $+commands[uv] )) || return

# --- uv/uvx completions ---
# Generate completion functions into a cache dir and ensure that dir is on $fpath.
# If compinit already ran before this plugin loaded, we re-run compinit only when needed.
UV_ZSH_COMPLETION_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
mkdir -p "$UV_ZSH_COMPLETION_DIR"
fpath=("$UV_ZSH_COMPLETION_DIR" $fpath)

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

# Generate completion files if missing OR if uv/uvx changed.
# We version-stamp the cache so completions auto-refresh on upgrade.
UV_COMPLETION_STAMP="$UV_ZSH_COMPLETION_DIR/.uv-completion-version"
UVX_COMPLETION_STAMP="$UV_ZSH_COMPLETION_DIR/.uvx-completion-version"

_uv_version="$(uv --version 2>/dev/null)"
_uv_cached=""
[[ -f "$UV_COMPLETION_STAMP" ]] && _uv_cached="$(<"$UV_COMPLETION_STAMP")"

if [[ ! -f "$UV_ZSH_COMPLETION_DIR/_uv" || "$_uv_version" != "$_uv_cached" ]]; then
  uv generate-shell-completion zsh >| "$UV_ZSH_COMPLETION_DIR/_uv" 2>/dev/null
  print -r -- "$_uv_version" >| "$UV_COMPLETION_STAMP" 2>/dev/null
fi

if (( $+commands[uvx] )); then
  _uvx_version="$(uvx --version 2>/dev/null)"
  _uvx_cached=""
  [[ -f "$UVX_COMPLETION_STAMP" ]] && _uvx_cached="$(<"$UVX_COMPLETION_STAMP")"

  if [[ ! -f "$UV_ZSH_COMPLETION_DIR/_uvx" || "$_uvx_version" != "$_uvx_cached" ]]; then
    uvx --generate-shell-completion zsh >| "$UV_ZSH_COMPLETION_DIR/_uvx" 2>/dev/null
    print -r -- "$_uvx_version" >| "$UVX_COMPLETION_STAMP" 2>/dev/null
  fi
fi

unset _uv_version _uv_cached _uvx_version _uvx_cached UV_COMPLETION_STAMP UVX_COMPLETION_STAMP UV_ZSH_COMPLETION_DIR _pip_shim_version _pipx_shim_version
