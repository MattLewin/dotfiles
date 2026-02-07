# git.plugin.zsh 

alias ga='git add'
alias gau='git add --update'
alias gb='git branch'
alias gc!='git commit --amend --verbose'
alias gc='git commit'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gdgui='git difftool --no-prompt'
alias gds='git diff --staged'
alias gitchanged='git fetch --all && git diff ...origin'
alias glg='git log --stat'
alias gp='git push'
alias gst='git status'
alias gsw='git switch'
alias gswc='git switch --create'

#
# ML: 2019-02-14
# git.io "GitHub URL"
#
# Shorten GitHub url, example:
#   https://github.com/nvogel/dotzsh    >   https://git.io/8nU25w
# source: https://github.com/nvogel/dotzsh
# documentation: https://github.com/blog/985-git-io-github-url-shortener
#
function gitio() {
    emulate -L zsh
    curl -i -s https://git.io -F "url=$1" | grep "Location" | cut -f 2 -d " "
}
