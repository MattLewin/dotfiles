# 13-aliases-bat.fish — bat/batcat equivalents for fish
# Auto-detect the correct executable on Ubuntu/Debian (batcat) vs others (bat)

# Pick the right command
if type -q bat
    set -g BAT bat
else if type -q batcat
    set -g BAT batcat
else
    set -g BAT ''
end

# If neither bat nor batcat is available, stop here.
if test -z "$BAT"
    exit
end

# --- Core replacements -------------------------------------------------------
# Make `cat` behave like cat with syntax highlighting
alias cat "$BAT --paging=never --style=plain"

# Pretty cat: header + grid borders, page if long
alias catp "$BAT --style=header,grid --paging=auto"

# Numbered output, no pager
alias catn "$BAT --style=numbers --paging=never"

# Concatenate multiple files with visible separators
alias catc "$BAT --style=header,grid --paging=never"

# --- Ranges & diffs ----------------------------------------------------------
# Show specific line ranges
# Usage: lines FILE START:END  (e.g., lines app.py 10:60)
function lines --description "bat a specific line range: lines FILE START:END"
    if test (count $argv) -ne 2
        echo "usage: lines FILE START:END" >&2
        return 2
    end
    $BAT --style=plain --paging=never --line-range $argv[2] $argv[1]
end

# Diff two files with bat highlighting
# Usage: batdiff A B
function batdiff --description "unified diff piped to bat"
    if test (count $argv) -ne 2
        echo "usage: batdiff FILE_A FILE_B" >&2
        return 2
    end
    diff -u --label $argv[1] --label $argv[2] $argv[1] $argv[2] \
        | $BAT -l diff --paging=always
end

# --- Git helpers (pretty output via bat) ------------------------------------
# Always page and highlight diffs/logs
function gshow --description "git show piped to bat (diff highlighting)"
    git show --no-color | $BAT -l diff --paging=always
end

function glog --description "git log -p piped to bat (diff highlighting)"
    git log -p --no-color | $BAT -l diff --paging=always
end

# View a file from a past commit
# Usage: gfile COMMIT -- PATH
function gfile --description "git show <commit> -- <path> piped to bat"
    if test (count $argv) -lt 1
        echo "usage: gfile COMMIT -- PATH" >&2
        return 2
    end
    git show $argv | $BAT --paging=always --style=header,grid
end

# --- Extras ------------------------------------------------------------------
# Make `less` pretty-print source files (use bat as pager)
alias less "$BAT --paging=always --decorations=always"
