# Examples: https://github.com/junegunn/fzf/wiki/examples

# fuzzy list all aliases
function aliases() {
    command=$(alias |
        ack --color --color-match=bright_blue --passthru '^[^=]+' |
        fzf-tmux --ansi --reverse --cycle --height=90% --query="$1" --multi --select-1 --exit-0 |
        cut -d "=" -f 1)
    echo $command
}

# fuzzy list all commands with manual
function cmd() {
    compgen -ca |
        sort --unique |
        grep --invert-match '^_' | # Remove all hidden commands that start with '_'
        fzf --ansi --reverse --cycle --height=90% --preview='man {}' --preview-window=right:75%
    # Only use `man {}` for preview since using `{} -h` may result in invoking the command
}

if ( [ ${commands[ack]} ] && [ "${BREW_PREFIX}" != "" ] )
then
    function brewlist() {
      result=$(brew list --versions |
        ack --color --color-match=bright_blue --passthru '^[^ ]+' |
        fzf --ansi --reverse --cycle |
        cut -d " " -f 1 |
        xargs)

      # Proceed if a module is selected
      [[ -n "$result" ]] && brew info $result
    }
fi

function gemlist() {
  gem list |
    ack --color --color-match=bright_blue --passthru '^[^ ]+' |
    fzf --ansi --reverse
}

unalias path NUL
function path() {
    local list=$(print -rl -- ${(s/:/)PATH} | ack --color --color-match=bright_blue '[/]')

    if [ ${commands[fzf]} ]; then
        $(print "$list" |
            fzf --ansi --no-sort --reverse --cycle --height=90%)
    else
        print "$list"
    fi
}

function piplist() {
  # pip list just the installed packages without its dependencies
  pip_list=$(pip list --not-required)

  printf "%s\n%s\n" " -- pip list --" "$pip_list" |
    ack --color --color-match=bright_blue --passthru '^[^ ]+' |
    fzf --ansi --reverse --cycle \
      --preview-window=70% \
      --preview=" echo {} | cut -d \" \" -f 1 | xargs pip show " |
    xargs
}

function pip3list() {
  # pip3 list just the installed packages without its dependencies
  pip3_list=$(pip3 list --not-required)

  printf "%s\n%s\n" " -- pip3 list --" "$pip3_list" |
    ack --color --color-match=bright_blue --passthru '^[^ ]+' |
    fzf --ansi --reverse --cycle \
      --preview-window=70% \
      --preview=" echo {} | cut -d \" \" -f 1 | xargs pip3 show " |
    xargs
}

# Overwrite env with colorized output
alias env="noglob env | sort --unique | ack --color --color-match=bright_blue --passthru '^[^=]+' | fzf --ansi --reverse --cycle --height=90%"

# Interactive history
function ih() {
  local fc_command='fc -ln -1000'
  if (( $# > 1 ))
  then
    fc_command="fc $@"
  else
    fc_command="fc -ln -${1:-1000}"
  fi

  eval "${fc_command}" | sort -u | ack --color --color-match=bright_blue --passthru '^[^ ]+' | fzf --reverse --cycle --height=90% --ansi
}
