if status is-interactive
    eval (direnv hook fish)
    starship init fish | source
    zoxide init fish | source

    # Make zoxide case-insensitive
    set -x _ZO_CASE 0
    set -x _ZO_FZF_OPTS "-i"
end
