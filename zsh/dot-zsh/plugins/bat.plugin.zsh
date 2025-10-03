# bat.plugin.zsh 

# --- Core replacements -------------------------------------------------------
# Make `cat` behave like cat with syntax highlighting
alias cat='bat --paging=never --style=plain'

# Pretty cat: header + grid borders, page if long
alias catp='bat --style=header,grid --paging=auto'

# Numbered output, no pager
alias catn='bat --style=numbers --paging=never'

# Concatenate multiple files with visible separators
alias catc='bat --style=header,grid --paging=never'

# --- Ranges & diffs ----------------------------------------------------------
# Show specific line ranges
# Usage: lines FILE START:END  (e.g., lines app.py 10:60)
lines() {
  if [[ $# -ne 2 ]]; then
    echo 'usage: lines FILE START:END' >&2
    return 2
  fi
  bat --style=plain --paging=never --line-range "$2" "$1"
}

# Diff two files with bat highlighting
# Usage: batdiff A B
batdiff() {
  if [[ $# -ne 2 ]]; then
    echo 'usage: batdiff FILE_A FILE_B' >&2
    return 2
  fi
  diff -u --label "$1" --label "$2" "$1" "$2" | bat -l diff --paging=always
}

# --- Git helpers (pretty output via bat) ------------------------------------
# Always page and highlight diffs/logs
alias gshow='git show --no-color | bat -l diff --paging=always'
alias glog='git log -p --no-color | bat -l diff --paging=always'

# View a file from a past commit
# Usage: gfile COMMIT -- PATH
gfile() {
  if [[ $# -lt 1 ]]; then
    echo 'usage: gfile COMMIT -- PATH' >&2
    return 2
  fi
  git show "$@" | bat --paging=always --style=header,grid
}

# --- Extras ------------------------------------------------------------------
# Make `less` pretty-print source files
alias less='bat --paging=always --decorations=always'
