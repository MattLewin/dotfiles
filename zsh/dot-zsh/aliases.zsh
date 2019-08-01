#
# Normal aliases (i.e., only work as $0)
#
alias agrep='alias | grep'
alias dirs='builtin dirs -v'
alias gdgui='git difftool --no-prompt'
alias gfi='git flow init --global --defaults'
alias gitignored='git ls-files --others -i --exclude-standard'
alias l='ls -lFh'       # List files as a long list, show size, type, human-readable
alias lS='ls -1FSsh'    # List files showing only size and name sorted by size
alias la='ls -lAFh'     # List almost all files as a long list show size, type, human-readable
alias lart='ls -1Fcart' # List all files sorted in reverse of create/modification time (oldest first)
alias ldot='ls -ld .*'  # List dot files as a long list
alias ll='ls -l'        # List files as a long list
alias lr='ls -tRFh'     # List files recursively sorted by date, show type, human-readable
alias lrt='ls -1Fcrt'   # List files sorted in reverse of create/modification time(oldest first)
alias lt='ls -ltFh'     # List files as a long list sorted by date, show type, human-readable
alias mp='man-preview'
alias mpa='man-preview-all'
alias nslookup6='nslookup -querytype=AAAA'
alias passgen='pass generate -nc'

#
# Global aliases
#  These aliases are expanded in any position in the command line, meaning you
#  can use them even at the end of the command you’ve typed
#
alias -g CA="2>&1 | cat -A"
alias -g G='| grep'
alias -g H='| head'
alias -g L="| less"
alias -g LL="2>&1 | less"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g T='| tail'

#
# Conditional aliases
#
test -x /usr/local/bin/howdoi && alias howdoi='/usr/local/bin/howdoi -c -n 3'
test -x /usr/local/bin/htop && alias top='/usr/local/bin/htop'

#
# Functions
#
function man-preview-all() {

    if [[ -z "$@" ]]; then
        echo "No man page specified"
        return 1
    fi

    local man_pdf_path="${MAN_PDF_PATH}"
    if [[ -z "$man_pdf_path" ]]; then
        MAN_PDF_PATH='${HOME}/Dropbox/Documents/Matt/Development/Man Pages'
    fi

    local output_file="${MAN_PDF_PATH}/$@"

    man -a -t "$@" > "${output_file}"

    if [[ $? = 1 ]]; then
        rm "${output_file}"
    else
        open -a Preview "${output_file}"
    fi
}

function ls-absolute() {

    # Note: This is not a well-written function. It properly handles no arguments and one, file specification, argument.
    #       It'll barf on switches, extra file specifications, and anything else you throw on the command-line
    if [[ -z "$1" ]]; then
        # Show everything
        /bin/ls -d -1 $PWD/**/*
    else
        for fn in $@; do
            /bin/ls -d -1 $PWD/$fn
        done
    fi
}


# ML: 2017-05-01
# ML: 2018-02-08 (updated for iTerm)
# open man pages in a new window
case "$TERM_PROGRAM" in
    iTerm.app)
        function mant () {
            osascript - "$@" <<EOF
                on run argv
                    tell application "iTerm"
                        activate
                        create window with profile "man" command "man " & item 1 of argv
                        tell current window
                            tell current session
                                set name to "man " & item 1 of argv
                            end tell
                        end tell
                    end tell
                end run
EOF
        }
        ;;

    Apple_Terminal)
        function mant() {
            if [ $# -eq 1 ]
            then
                open x-man-page://$1
            elif [ $# -eq 2 ]
            then
                open x-man-page://$1/$2
            fi
        }
        ;;

    *)
        alias mant='man'
        ;;
esac

# ML: 2017-05-17
# replace 'man' with 'pinfo' and 'top' with 'htop'
#if [ -x /usr/local/bin/pinfo ]; then
#   alias man='/usr/local/bin/pinfo -m'
#fi


# Add aliases for all existing JetBrains apps
# ML: 2018-06-20: commented out because JetBrains Toolbox creates its own launch scripts for each app
# if [ -e "$HOME/Applications/JetBrains Toolbox/" ]; then
#     for JBAPP in $HOME/Applications/JetBrains\ Toolbox/*.app; do
#       local JBAPP_NAME=${JBAPP:t:r}
#       local JBAPP_ALIAS=${${JBAPP:t:r:l}[(w)1]}
#       alias $JBAPP_ALIAS="open -a ${JBAPP_NAME:q}"
#     done
#     unset JBAPP
# fi

# ML: 2018-01-05
# A few tools to ease gem installation between ruby versions
function gemdiff() {
    if [ $# != 2 ]; then
        print -u 2 "gemdiff old_version new_version"
        return 1
    fi

    function install_all_gems() {
        local next_gem=$((gem list | cut -f 1 -d ' ') | comm -23 ${old_gemlist} - | head -1)
        while [ -n "$next_gem" ]
        do
            print "Installing ${next_gem}"
            local install_cmd="gem install ${next_gem} --document rdoc"
            eval ${install_cmd}
            next_gem=$((gem list | cut -f 1 -d ' ') | comm -23 ${old_gemlist} - | head -1)
        done
    }

    local old=$1
    local old_gemlist="$HOME/src/tmp/gems-${old}.txt"
    local new=$2
    local new_gemlist="$HOME/src/tmp/gems-${new}.txt"

    rvm use ${old} || (print -u 2 "Unable to switch to ruby version ${old}"; return 1)
    gem list | cut -f 1 -d ' ' > ${old_gemlist}

    if [ ! -f ${old_gemlist} ]; then
        print -u 2 "Unable to generate ${old_gemlist}"
        return 3
    fi

    rvm use ${new} || (print -u 2 "Unable to switch to ruby version ${new}"; return 1)
    print "Installing gems from ${old} to ${new}"
    install_all_gems
}

case "$OS" in
    mac)
        test -d "/Applications/SourceTree.app" && alias sourcetree='open -a /Applications/SourceTree.app'
        test -d "/Applications/VLC.app" && alias vlc='/Applications/VLC.app/Contents/MacOS/VLC -I rc'
        alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; say DNS cache flushed' # For use after editing /etc/hosts

        # allow easily switching between Java versions
        JAVA_VERSIONS=({5..20})
        for ver in $JAVA_VERSIONS; do
            if ((${ver} < 9)) ; then
                ver_str="1.${ver}"
            else
                ver_str=$ver
            fi
            cmd="/usr/libexec/java_home -v$ver_str"
            if eval $cmd >/dev/null 2>&1; then
                export JAVA_${ver}_HOME=$(eval $cmd)
                alias java${ver}="export JAVA_HOME=\$JAVA_${ver}_HOME"
            fi
        done
        unset JAVA_VERSIONS
        # default to java8 if it exists
        test -n "$JAVA_8_HOME" && export JAVA_HOME=$JAVA_8_HOME
        ;;

    linux)
        test -d "/usr/lib/jvm/default-java" && export JAVA_HOME=/usr/lib/jvm/default-java
        ;;

    *) # No idea what platorm we are on
esac

#
# ML: 2019-02-14
# git.io "GitHub URL"
#
# Shorten GitHub url, example:
#   https://github.com/nvogel/dotzsh    >   https://git.io/8nU25w
# source: https://github.com/nvogel/dotzsh
# documentation: https://github.com/blog/985-git-io-github-url-shortener
#
function git.io() {
    emulate -L zsh
    curl -i -s https://git.io -F "url=$1" | grep "Location" | cut -f 2 -d " "
}

#
# ML: 2019-07-15
# A function to display the tmux window number
func tmux_winidx_circled() {
    local winidx=$(tmux display-message -p '#I')
    if (( winidx > 20 )); then
        echo "($winidx)"
    else
        echo "${circled_digits:$winidx:1}"
    fi
}

#
# TrueMotion Aliases
#
if [ "$(hostname)" = "bos075" ]; then
    function tmo_repo_install() {
        bundle install
        git submodule update --init --recursive
        [ -e "Podfile" ] && bundle exec pod install $@
    }
fi
