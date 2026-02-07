if status is-interactive
    type -q direnv; and eval (direnv hook fish)
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
    type -q mise; and mise activate fish | source

    # Make zoxide case-insensitive
    set -x _ZO_CASE 0
    set -x _ZO_FZF_OPTS "-i"
end
