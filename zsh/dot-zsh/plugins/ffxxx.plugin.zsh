# ffxxx.plugin.zsh
# Wrappers for ffmpeg, ffplay, ffprobe:
# - always -hide_banner
# - auto-select libdav1d when the detected input is AV1

# Find first input after -i in argv (ffmpeg-style).
__ffav1_first_input_after_i() {
  local -a args; args=("$@")
  local i
  for (( i=1; i <= ${#args[@]}; i++ )); do
    if [[ "${args[i]}" == "-i" && $((i+1)) -le ${#args[@]} ]]; then
      print -r -- "${args[i+1]}"
      return 0
    fi
  done
  return 1
}

# Find first non-option argument (ffplay positional input).
# Heuristic: returns the first argument that exists as a file or looks like a URL.
__ffav1_first_positional() {
  local arg
  local end_opts=0
  for arg in "$@"; do
    if [[ $end_opts -eq 1 ]]; then
      print -r -- "$arg"
      return 0
    fi
    if [[ "$arg" == "--" ]]; then
      end_opts=1
      continue
    fi
    [[ "$arg" == -* ]] && continue
    if [[ -f "$arg" ]] || [[ "$arg" =~ ^[a-zA-Z]+:// ]]; then
      print -r -- "$arg"
      return 0
    fi
  done
  return 1
}

# Probe codec of first video stream. Prints codec_name (e.g., "av1") or nothing on failure.
__ffav1_probe_vcodec() {
  local input="$1"
  [[ -z "$input" ]] && return 1

  command ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=codec_name \
    -of default=nk=1:nw=1 \
    -- "$input" 2>/dev/null
}

__ffav1_is_av1_input() {
  local input="$1"
  local vcodec
  vcodec="$(__ffav1_probe_vcodec "$input")"
  [[ "$vcodec" == "av1" ]]
}

# ffmpeg wrapper: check first -i input only
ffmpeg() {
  local input=""
  input="$(__ffav1_first_input_after_i "$@")" || true

  if [[ -n "$input" ]] && __ffav1_is_av1_input "$input"; then
    command ffmpeg -hide_banner -c:v libdav1d "$@"
  else
    command ffmpeg -hide_banner "$@"
  fi
}

# ffplay wrapper: check first positional input (or -i if used)
ffplay() {
  local input=""

  # Prefer -i if present, otherwise positional
  input="$(__ffav1_first_input_after_i "$@")" || input="$(__ffav1_first_positional "$@")" || true

  if [[ -n "$input" ]] && __ffav1_is_av1_input "$input"; then
    command ffplay -hide_banner -vcodec libdav1d "$@"
  else
    command ffplay -hide_banner "$@"
  fi
}

# ffprobe wrapper: always hide banner
ffprobe() {
  command ffprobe -hide_banner "$@"
}
