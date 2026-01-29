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
# Stops option parsing at "--" and returns the first positional after it.
# Skips values consumed by common options that take an argument.
__ffav1_first_positional() {
  local -a args; args=("$@")
  local i=1
  local a

  while (( i <= ${#args[@]} )); do
    a="${args[i]}"

    # End of options; next token (if any) is positional input
    if [[ "$a" == "--" ]]; then
      (( i++ ))
      [[ $i -le ${#args[@]} ]] && { print -r -- "${args[i]}"; return 0; }
      return 1
    fi

    # If it doesn't start with '-', it's positional input
    if [[ "$a" != -* ]]; then
      print -r -- "$a"
      return 0
    fi

    # Option takes a following argument (skip it)
    case "$a" in
      # common across ffmpeg/ffplay
      -i|-ss|-t|-to|-itsoffset|-vf|-af|-filter_complex|-s|-r|-aspect|-vn|-an|-sn|-dn|-sync|-pix_fmt|-f|-c|-codec|-vcodec|-acodec|-scodec|-map|-lavfi|-protocol_whitelist|-hwaccel|-hwaccel_device|-hwaccel_output_format|-threads|-framerate|-video_size|-pixel_format|-sample_rate|-channels|-audio_buffer_size|-seek_interval|-window_title|-x|-y|-left|-top|-loop)
        (( i+=2 ))
        continue
        ;;
      # options in the form -vf=... or -x=...
      -*=*)
        (( i++ ))
        continue
        ;;
      *)
        (( i++ ))
        continue
        ;;
    esac
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
