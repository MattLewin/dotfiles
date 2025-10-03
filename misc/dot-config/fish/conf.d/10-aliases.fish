
# git
alias ga='git add'
alias gau='git add --update'
alias gb='git branch'
alias gc='git commit'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcue-hoos='git config set user.email mail@hoosfoosmccave.com'
alias gcue-matt='git config set user.email matt@mogroups.com'
alias gcun-hoos='git config set user.name "Hoosfoos McCave"'
alias gcun-matt='git config set user.name "Matt Lewin"'
alias gd='git diff'
alias gitchanged='git fetch --all && git diff ...origin'
alias gitconfig-hoos='gcue-hoos ; gcun-hoos'
alias gitconfig-matt='gcue-matt ; gcun-matt'    
alias glg='git log --stat'
alias gp='git push'
alias gst='git status'
alias gsw='git switch'
alias gswc='git switch --create'

# the many flavors of ls
alias l="ls -lFh"       # List files as a long list, show size, type, human-readable
alias lS="ls -1FSsh"    # List files showing only size and name sorted by size
alias la="ls -lAFh"     # List almost all files as a long list show size, type, human-readable
alias ldot="ls -ld .*"  # List dot files as a long list
alias ll="ls -l"        # List files as a long list
alias lt="ls -ltFh"     # List files as a long list sorted by date, show type, human-readable
