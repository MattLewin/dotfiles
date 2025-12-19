if type -q color2hex
    set -l compfile ~/.config/fish/completions/color2hex.fish
    set -l cmd (command -v color2hex)

    if not test -e $compfile; or test $cmd -nt $compfile
        mkdir -p (dirname $compfile)
        color2hex completion fish > $compfile ^/dev/null
    end
end
