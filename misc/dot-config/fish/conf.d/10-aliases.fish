
# git
alias gcue-hoos='git config set user.email mail@hoosfoosmccave.com'
alias gcue-matt='git config set user.email matt@mogroups.com'
alias gcun-hoos='git config set user.name "Hoosfoos McCave"'
alias gcun-matt='git config set user.name "Matt Lewin"'
alias gitchanged='git fetch --all && git diff ...origin'
alias gitconfig-hoos='gcue-hoos ; gcun-hoos'
alias gitconfig-matt='gcue-matt ; gcun-matt'    

# the many flavors of ls
alias l="ls -lFh"       # List files as a long list, show size, type, human-readable
alias lS="ls -1FSsh"    # List files showing only size and name sorted by size
alias la="ls -lAFh"     # List almost all files as a long list show size, type, human-readable
alias ldot="ls -ld .*"  # List dot files as a long list
alias ll="ls -l"        # List files as a long list
alias lt="ls -ltFh"     # List files as a long list sorted by date, show type, human-readable

# maintenance
alias update-ubuntu='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
