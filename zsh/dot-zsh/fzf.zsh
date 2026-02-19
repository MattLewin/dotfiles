# Examples: https://github.com/junegunn/fzf/wiki/examples

# fuzzy list commands/aliases/functions with safe preview
function cmd() {
  local sel

  sel=$(
    {
      # external commands on $PATH
      print -rl -- ${(k)commands}
      # zsh builtins
      print -rl -- ${(k)builtins}
      # aliases
      print -rl -- ${(k)aliases}
      # functions (optional, but useful when browsing)
      print -rl -- ${(k)functions}
    } 2>/dev/null \
      | sort -u \
      | grep -v '^_' \
      | fzf --ansi --reverse --cycle --height=90% \
          --preview='(man {1} 2>/dev/null || whence -v {1} 2>/dev/null || echo "(no help for {1})") | sed -n "1,160p"' \
          --preview-window=right:75%
  ) || return

  # Put the selection into your command line buffer for easy execution/editing
  print -z -- "$sel"
}

if (( $+commands[rg] )) && [[ -n "${BREW_PREFIX}" ]]
then
    function brewlist() {
      result=$(brew list --versions |
        rg --color=always '^[^ ]+' |
        fzf --ansi --reverse --cycle |
        cut -d " " -f 1 |
        xargs)

      # Proceed if a module is selected
      [[ -n "$result" ]] && brew info $result
    }
fi

function gemlist() {
  gem list |
    rg --color=always '^[^ ]+' |
    fzf --ansi --reverse
}

unalias path >/dev/null 2>&1
function path() {
    local list=$(print -rl -- ${(s/:/)PATH} | rg --color=always '[/]')

    if (( $+commands[fzf] )); then
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
    rg --color=always '^[^ ]+' |
    fzf --ansi --reverse --cycle \
      --preview-window=70% \
      --preview=" echo {} | cut -d \" \" -f 1 | xargs pip show " |
    xargs
}

function pip3list() {
  # pip3 list just the installed packages without its dependencies
  pip3_list=$(pip3 list --not-required)

  printf "%s\n%s\n" " -- pip3 list --" "$pip3_list" |
    rg --color=always '^[^ ]+' |
    fzf --ansi --reverse --cycle \
      --preview-window=70% \
      --preview=" echo {} | cut -d \" \" -f 1 | xargs pip3 show " |
    xargs
}

# Overwrite env with colorized output
alias env="noglob env | sort --unique | rg --color=always '^[^=]+' | fzf --ansi --reverse --cycle --height=90%"

# Display all zsh variables with colorized output
alias vars='set | sort --unique | rg --color=always "^[^=]+" | fzf --ansi --reverse --cycle --height=90%'

# Interactive history
function ih() {
  local fc_command='fc -ln -1000'
  if (( $# > 1 ))
  then
    fc_command="fc $@"
  else
    fc_command="fc -ln -${1:-1000}"
  fi

  eval "${fc_command}" | sort -u | rg --color=always '^[^ ]+' | fzf --reverse --cycle --height=90% --ansi
}

# Display all zsh functions and select one to view its definition with colorized output
funcs() {
  local f def

  f=$(
    print -rl -- ${(k)functions} \
    | grep -v '^_' \
    | sort -u \
    | fzf --prompt='function> ' \
          --height=90% --reverse --cycle \
          --preview 'functions -- {} | sed -n "1,120p"'
  ) || return

  def=$(functions -- "$f") || return

  if (( $+commands[bat] )); then
    print -r -- "$def" | bat --language=zsh --paging=always
  else
    print -r -- "$def" | ${PAGER:-less} -R
  fi
}
