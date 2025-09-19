#
# Normal aliases (i.e., only work as $0)
#
alias dirs='builtin dirs -v'
alias dirsc='builtin dirs -c'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias gcue-hoos='git config set user.email mail@hoosfoosmccave.com'
alias gcue-matt='git config set user.email matt@mogroups.com'
alias gcun-hoos='git config set user.name "Hoosfoos McCave"'
alias gcun-matt='git config set user.name "Matt Lewin"'
alias gdgui='git difftool --no-prompt'
alias gfi='git flow init --global --defaults'
alias gitchanged='git fetch --all && git diff ...origin'
alias gitconfig-hoos='gcue-hoos ; gcun-hoos'
alias gitconfig-matt='gcue-matt ; gcun-matt'
alias gitignored='git ls-files --others -i --exclude-standard'
alias hgrep='fc -il 0 | grep'
alias hrg='fc -il 0 | rg'
# shellcheck disable=SC2142
alias hr='_hr() { for c in "${@:--}"; do cols="$(tput cols)"; [ "${cols}" -le "0" ] && cols="80"; printf "%*s" "${cols}" "" | tr " " "$(printf "%c" "${c}")"; done }; _hr' # <HR/> for shells
alias l="ls -lFh"       # List files as a long list, show size, type, human-readable
alias lS="ls -1FSsh"    # List files showing only size and name sorted by size
alias la="ls -lAFh"     # List almost all files as a long list show size, type, human-readable
alias ldot="ls -ld .*"  # List dot files as a long list
alias ll="ls -l"        # List files as a long list
alias lt="ls -ltFh"     # List files as a long list sorted by date, show type, human-readable
alias nslookup6='nslookup -querytype=AAAA'
alias pbc='clipcopy'
alias ping="ping -c 5"
alias ping6='ping -6 -c 5'
alias stat='zstat -s'

#
# Global aliases
#  These aliases are expanded in any position in the command line, meaning you
#  can use them even at the end of the command you’ve typed
#
alias -g CA="2>&1 | cat -A"
alias -g G='| rg'
(( $+commands[gvim] )) && alias -g GVIM='| gvim -'
alias -g H='| head'
alias -g L="| less"
alias -g LL="2>&1 | less"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g T='| tail'
alias -g VI='| vi -'

#
# Suffix aliases
#  These aliases are triggered by extensions.
#  Ex.: alias -s cpp=vim
#       will cause `$ foo.cpp` to open foo.cpp in vim
autoload -Uz is-at-least
if is-at-least 4.2.0; then
    if [[ -n "$BROWSER" ]]; then
        _browser_fts=(htm html de org net com at cx nl se dk)
        for ft in $_browser_fts; do alias -s $ft=$BROWSER; done
    fi

    if [[ -n "$EDITOR" ]]; then
        _editor_fts=(c cc cpp cxx h hh txt TXT)
        for ft in $_editor_fts; do alias -s $ft=$EDITOR; done
    fi

    if [[ -n "$XIVIEWER" ]]; then
        _image_fts=(jpg jpeg png gif mng tiff tif xpm)
        for ft in $_image_fts; do alias -s $ft=$XIVIEWER; done
    fi

    #list whats inside packed file
    alias -s zip="unzip -l"
    alias -s tar="tar tf"

    # display markdown files
    if (( $+commands[pandoc] )); then
        PANDOC_BIN="${commands[pandoc]}"
        if (( $+commands[w3m] )); then
            TEXT_BROWSER='w3m -T text/html'
            PANDOC_CMD="${PANDOC_BIN}"
        elif (( $+commands[lynx] )); then
            TEXT_BROWSER='lynx -stdin'
            PANDOC_CMD="${PANDOC_BIN}"
        elif [[ -n "${PAGER}" ]]; then
            TEXT_BROWSER=${PAGER}
            PANDOC_CMD="${PANDOC_BIN} -t plain"
        else
            TEXT_BROWSER='less'
            PANDOC_CMD="${PANDOC_BIN} -t plain"
        fi

        function display_markdown_file() {
            if [[ $# != 1 ]]; then
                print "$0 <markdown file>"
                return 1
            fi
            local -a pandoc_cmd text_browser
            pandoc_cmd=(${=PANDOC_CMD})
            text_browser=(${=TEXT_BROWSER})
            "${pandoc_cmd[@]}" -- "${PWD}/${1}" | "${text_browser[@]}"
        }
        alias -s md="display_markdown_file"
        alias -s MD="display_markdown_file"
    fi
fi

#
# If fzf is installed, load all related aliases and functions
#
(( $+commands[fzf] )) && test -f "${DOT_ZSH}/fzf.zsh" && source "${DOT_ZSH}/fzf.zsh"

#
# Conditional aliases
#

# Use $+commands[...] to safely check for command existence without erroring if unset

if (( $+commands[cataclysm] )); then
  function cataclysm() {
    command cataclysm "$@" > /dev/null 2>&1 &
    disown
  }
fi

if (( $+commands[fd] )); then
    alias find='fd --no-ignore'
    alias find.d='fd --no-ignore --type directory'
    alias find.f='fd --no-ignore --type file'
else
    alias find.d='find . -type d -name'
    alias find.f='find . -type f -name'
fi

(( $+commands[howdoi] )) && alias howdoi="${commands[howdoi]} -c -n 3"
(( $+commands[htop] )) && alias top="${commands[htop]}"

# Prefer python3; avoid symlinking system python
if (( $+commands[python3] )); then
    alias python=python3
fi

#
# Functions
#

# Calculate the complement of a hex color
function complement_color() {
  if [[ -z "$1" ]]; then
    echo "Usage: complement_color <hex_color_code>"
    echo "Example: complement_color 33A1C9"
    return 1
  fi

  # Get the input color and strip '#' if present
  local input_hex=${1#"#"}

  # Ensure it's a valid hex code
  if [[ ! "$input_hex" =~ ^[0-9a-fA-F]{6}$ ]]; then
    echo "Error: Invalid hex color code. Must be in the form #RRGGBB or RRGGBB."
    return 1
  fi

  # Convert hex to decimal RGB
  local red=$(( 16#${input_hex[1,2]} ))
  local green=$(( 16#${input_hex[3,4]} ))
  local blue=$(( 16#${input_hex[5,6]} ))

  # Calculate the complement
  local comp_red=$((255 - red))
  local comp_green=$((255 - green))
  local comp_blue=$((255 - blue))

  # Convert back to hex and print
  printf "#%02X%02X%02X\n" $comp_red $comp_green $comp_blue
}

function random() {
    if [[ $# != 1 ]]; then
        print '"random <max_value>" : print a random integer between 1 and max_value (inclusive)'
        return 1
    fi

    print $((1 + $(od -A n -t d -N1 /dev/random) % $1))
}

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

# clone of the old DOS 'pause' command
function pause() {
    read -rs -k1 "?Press any key to continue..."$'\n'
}

#
# ML: 2019-07-15
# A function to display the tmux window number
function tmux_winidx_circled() {
    if tmux info &> /dev/null; then
        local winidx
        winidx=$(tmux display-message -p '#I')
        if (( winidx > 20 )); then
            echo "($winidx)"
        else
            echo "${circled_digits:$winidx:1}"
        fi
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

case "$OS" in
    mac|darwin)
        test -d "/Applications/VLC.app" && alias vlc='/Applications/VLC.app/Contents/MacOS/VLC -I rc'
        alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; say DNS cache flushed' # For use after editing /etc/hosts
        ;;

    linux)
        test -d "/usr/lib/jvm/default-java" && export JAVA_HOME=/usr/lib/jvm/default-java
        ;;

    *) # No idea what platorm we are on
esac

if [ "${BREW_PREFIX}" != "" ]; then

    alias brewoutdated='print -c $( brew outdated | cut -f1 -d" ")'
    alias brewuses='brew uses --installed --recursive'

    if (( $+commands[fortune] )) && (( $+commands[cowsay] )); then
        local _brew_prefix="${HOMEBREW_PREFIX:-$BREW_PREFIX}"
        COWS=($_brew_prefix/share/cowsay/cows/*.cow)

        function cowrandom() {
            local count
            count=$(ls $_brew_prefix/share/cowsay/cows/*.cow | wc -l)
            local RAND_COW=$(( RANDOM % count ))
            fortune | cowsay -f ${COWS[$RAND_COW]}
        }

        cowrandom
    fi

    #
    # 'brew --prefix golang' is very slow, so let's only do it if/when we use go
    #
    if (( $+commands[go] )); then
        function go() {
            test -d "$HOME/.go" && export GOPATH="$HOME/.go"
            (( $+commands[brew] )) && export GOROOT="$(brew --prefix golang)/libexec"
            unfunction go
            ${commands[go]} "$@"
        }
    fi
fi

#
# Remove aliases I don't want to use
#
unalias gl NUL # Unalias 'git pull' from git plugin
