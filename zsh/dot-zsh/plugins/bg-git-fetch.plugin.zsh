# Idle git fetch for zsh.
#
# Runs a quiet `git fetch` periodically when the shell is idle and the current working
# directory is inside a git worktree.
#
# Configuration:
#   - BG_GIT_FETCH_PERIOD: interval in seconds (default: 300)
#
# Notes:
#   - Uses the zsh `periodic()` hook; does not touch prompt hooks directly.
#   - Redirects all output to avoid interfering with Starship or other prompts.
#   - Sets GIT_TERMINAL_PROMPT=0 and SSH BatchMode to avoid blocking for input.

# Allow user config before plugin loads.
: "${BG_GIT_FETCH_PERIOD:=300}"
export PERIOD="$BG_GIT_FETCH_PERIOD"

# Track last-fetch time per repo top-level to avoid repeated fetches when cd'ing.
typeset -gA __bgfetch_last
__bgfetch_last=()

__bgfetch_top() {
  command git rev-parse --show-toplevel 2>/dev/null
}

__bgfetch_inrepo() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# If something else already defined periodic(), chain it.
if (( ${+functions[periodic]} )); then
  functions[__bgfetch_prev_periodic]="${functions[periodic]}"
fi

periodic() {
  (( ${+functions[__bgfetch_prev_periodic]} )) && __bgfetch_prev_periodic

  local top now last
  top="$(__bgfetch_top)" || return 0

  now=$EPOCHSECONDS
  last=${__bgfetch_last[$top]:-0}

  # Throttle per repo.
  (( now - last >= PERIOD )) || return 0

  __bgfetch_inrepo || return 0

  # Must have at least one remote.
  command git remote >/dev/null 2>&1 || return 0

  __bgfetch_last[$top]=$now

  GIT_TERMINAL_PROMPT=0 \
  GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5' \
  command git fetch --quiet --prune >/dev/null 2>&1
}
