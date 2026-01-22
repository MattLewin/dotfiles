#
# Normal aliases (i.e., only work as $0)
#
alias d-='popd -q'
alias d='builtin dirs -v'
alias dirsc='builtin dirs -c'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias hgrep='fc -il 0 | grep'
alias hrg='fc -il 0 | rg'
# shellcheck disable=SC2142
alias hr='_hr() { for c in "${@:--}"; do cols="$(tput cols)"; [ "${cols}" -le "0" ] && cols="80"; printf "%*s" "${cols}" "" | tr " " "$(printf "%c" "${c}")"; done }; _hr' # <HR/> for shells
alias nslookup6='nslookup -querytype=AAAA'
alias pbc='clipcopy'
alias ping="ping -c 5"
alias ping6='ping -6 -c 5'
alias stat='zstat -s'
alias update-all='antidote update && hr && mise upgrade && hr && brew upgrade'
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

if (( $+commands[nvim] )); then
    alias vi=nvim
    alias vim=nvim
fi

# Prefer python3; avoid symlinking system python
if (( $+commands[python3] )); then
    alias python=python3
fi

#
# Functions
#

# Calculate the complement of a hex color
complement_color() {
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

# Apply effects to audio -- intended for dialogue
lofi() {
  local do_radio=false
  local do_wt=false
  local input=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -radio) do_radio=true; shift ;;
      -wt)    do_wt=true; shift ;;
      *)      input="$1"; shift ;;
    esac
  done

  if [[ "$do_radio" = false && "$do_wt" = false ]] || [[ -z "$input" ]]; then
    echo "Usage: lofi [-radio] [-wt] <file>"
    return 1
  fi

  local base="${input%.*}"
  local ext="${input##*.}"
  
  # Standardize loudness and crush the dynamics
  local norm="loudnorm=I=-16:TP=-1.5:LRA=11"
  local comp="compand=0.3|0.3:6|6:-70/-60|-20/-14"
  
  # Target set dBFS for output by adjusting value of "limit" below
  # -1dBFS: 0.89
  # -3dBFS: 0.707
  # -6dBFS: 0.5
  # -10dBFS: 0.316
  local peak_cap="alimiter=limit=0.316:level=0"

  if [[ "$do_radio" = true ]]; then
    ffmpeg -i "$input" -af \
    "${norm},${comp},firequalizer=gain='if(between(f,400,3500),0,-60)+if(between(f,1000,2000),6,0)',aresample=48000,${peak_cap}" \
    -c:a pcm_s24le "${base}-radio.${ext}"
  fi

  if [[ "$do_wt" = true ]]; then
    ffmpeg -i "$input" -af \
    "${norm},${comp},firequalizer=gain='if(between(f,600,2500),0,-70)',aresample=48000,${peak_cap}" \
    -c:a pcm_s24le "${base}-wt.${ext}"
  fi
}

random() {
    if [[ $# != 1 ]]; then
        print '"random <max_value>" : print a random integer between 1 and max_value (inclusive)'
        return 1
    fi

    print $((1 + $(od -A n -t u -N4 /dev/random) % $1))
}

# clone of the old DOS 'pause' command
pause() {
    read -rs -k1 "?Press any key to continue..."$'\n'
}

#
# ML: 2019-07-15
# A function to display the tmux window number
tmux_winidx_circled() {
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
