# copypath.plugin.zsh — copy a path to the system clipboard.
# Vendored from the Oh My Zsh plugin, minus its dependency on OMZ's
# lib/clipboard.zsh (which Antidote never sourced, so `clipcopy` was undefined).

# Pick a clipboard command once, at load time.
_copypath_clip() {
  if (( $+commands[pbcopy] )); then
    pbcopy
  elif (( $+commands[wl-copy] )); then
    wl-copy
  elif (( $+commands[xclip] )); then
    xclip -selection clipboard -in
  elif (( $+commands[xsel] )); then
    xsel --clipboard --input
  else
    print -r -- "copypath: no clipboard command found" >&2
    return 127
  fi
}

# Copy the path of the given file or directory; defaults to $PWD.
copypath() {
  local file="${1:-.}"

  # Relative paths are resolved against $PWD
  [[ $file = /* ]] || file="$PWD/$file"

  # :a makes the path absolute without resolving symlinks
  print -n "${file:a}" | _copypath_clip || return 1

  print -r -- "${file:a} copied to clipboard"
}
