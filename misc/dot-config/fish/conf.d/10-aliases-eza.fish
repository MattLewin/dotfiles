
if type -q eza
    set -g eza_base --color=auto --icons --group-directories-first

    alias ls "eza $eza_base"

    # cd then list
    function cdls --description "cd then list (all, long, git)"
        cd $argv[1]; or return
        eza -lah --git $eza_base
    end

    # long + sizes + git
    alias l     "eza -lh --git $eza_base"
    # convenience ll -> same as l
    alias ll    "eza -lh --git $eza_base"
    # one per line
    alias l1    "eza -1 $eza_base"
    # long + almost all + classify + human
    alias la    "eza -lAh --classify $eza_base"
    # dotfiles only (names)
    alias ldot  "eza -d .* $eza_base"
    # long + all + git
    alias lla   "eza -lah --git $eza_base"
    # long + dotfiles only
    alias lldot "eza -ld .* $eza_base"
    # long, sort by mtime (relative), type markers
    alias lt    "eza -l -s modified --time-style=relative --classify $eza_base"
    # tree view (default depth 2)
    alias ltree "eza -alhT --git-ignore --level=2 $eza_base"
    # quick deeper tree (depth 3)
    alias ltr   "eza -alhT --git-ignore --level=3 $eza_base"
    # size-sorted, human, show total
    alias lS    "eza -1 -s size -lh --classify --total-size $eza_base"
    # recent first (alt to lt without classify)
    alias ltmod "eza -l -s modified --time-style=relative $eza_base"
    # show octal permissions
    alias lperm "eza -l --octal-permissions $eza_base"
    # file type markers only
    alias ltype "eza -l --classify $eza_base"

else
    # Fallbacks if eza isn't installed
    alias l      "ls -lFh"
    alias lS     "ls -1FSsh"
    alias la     "ls -A"
    alias ldot   "ls -d .*"
    alias ll     "ls -l"
    alias lla    "ls -la"
    alias lldot  "ls -ld .*"
    alias lt     "ls -ltFh"
    function cdls --description "cd then list (all)"
        cd $argv[1]; or return
        ls -la
    end
end
