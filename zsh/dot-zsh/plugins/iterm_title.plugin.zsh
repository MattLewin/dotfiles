# iterm_title.plugin.zsh — minimal tab/window title support (no OMZ deps)

# Print escape sequences safely
__title_print() {
  # usage: __title_print target payload
  # targets: 0=both, 1=tab, 2=window
  local target="$1" text="$2"
  case "$target" in
    0) print -Pn -- "\e]0;$text\a" ;;  # both
    1) print -Pn -- "\e]1;$text\a" ;;  # tab
    2) print -Pn -- "\e]2;$text\a" ;;  # window
  esac
}

# Set titles on each prompt (idle state)
_termsupport_precmd() {
  # Tab: short PWD; Window: user@host:short PWD
  __title_print 1 "%~"
  __title_print 2 "%n@%m:%~"
}

# Set tab title to the command about to run
_termsupport_preexec() {
  # $1 is the raw command line; show a trimmed version
  local cmd="${1%%$'\n'*}"
  # Fall back if empty (e.g., ENTER)
  [[ -n "$cmd" ]] || cmd="zsh"
  __title_print 1 "$cmd"
}

# Hook in without clobbering existing handlers
typeset -a precmd_functions preexec_functions
precmd_functions+=(_termsupport_precmd)
preexec_functions+=(_termsupport_preexec)

# Initial titles for the very first prompt of a fresh shell
_termsupport_precmd
