# eza.plugin.zsh

if command -v eza >/dev/null 2>&1; then
  # Defaults: color, icons (Terminal.app/iTerm2), git info, dirs first
  _EZA_BASE=(--color=auto --icons --group-directories-first)

  alias ls='eza "${_EZA_BASE[@]}"'

  alias l='eza -lh --git "${_EZA_BASE[@]}"'               # long + sizes + git
  alias ll='l'                                            # convenience alias
  alias l1='eza -1 "${_EZA_BASE[@]}"'                     # one per line
  alias la='eza -lAh --classify "${_EZA_BASE[@]}"'        # long + almost all + classify + human
  alias ldot='eza -d .* "${_EZA_BASE[@]}"'                # dotfiles only
  alias lla='eza -lah --git "${_EZA_BASE[@]}"'            # long + all + git
  alias lldot='eza -ld .* "${_EZA_BASE[@]}"'              # dotfiles only
  alias lt='eza -l -s modified --time-style=relative --classify "${_EZA_BASE[@]}"'  # long, sort by mtime
  alias ltree='eza -alhT --git-ignore --level=${EZA_LVL:-2} "${_EZA_BASE[@]}"'      # tree (default depth 2)
  alias ltr='EZA_LVL=3 lt'                                # quick deeper tree
  alias lS='eza -1 -s size -lh --classify --total-size "${_EZA_BASE[@]}"'    # one per line, sort by size, human
  alias ltmod='eza -l -s modified --time-style=relative "${_EZA_BASE[@]}"'   # recent first
  alias lperm='eza -l --octal-permissions "${_EZA_BASE[@]}"'                 # show 0755 etc.
  alias ltype='eza -l --classify "${_EZA_BASE[@]}"'       # file type markers

else # Fallback if eza isn’t installed

  alias l="ls -lFh"       # long list, show size, type, human-readable
  alias lS="ls -1FSsh"    # show only size and name sorted by size
  alias la="ls -A"        # almost all files
  alias ldot="ls -d .*"   # dot files as a long list
  alias ll="ls -l"        # long list
  alias lla="ls -la".     # all files, long
  alias lldot="ls -ld .*" # dot files as a long list
  alias lt="ls -ltFh"     # long list sorted by date, show type, human-readable

fi

# Jump + list
cdls() { cd "${1:-$HOME}" && lla; }
