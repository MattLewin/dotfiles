# aliases
alias ga='git add'
alias gau='git add --update'
alias gb='git branch'
alias gc='git commit'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gitchanged='git fetch --all && git diff ...origin'
alias glg='git log --stat'
alias gp='git push'
alias gst='git status'
alias gsw='git switch'
alias gswc='git switch --create'

# abbreviations
abbr -a -- gc! 'git commit --amend --verbose'
abbr -a -- gds 'git diff --staged'
abbr -a -- gitignored 'git ls-files --others -i --exclude-standard'
