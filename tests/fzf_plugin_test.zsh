#!/usr/bin/env zsh -f
# Tests for zsh/dot-zsh/plugins/fzf.plugin.zsh. fzf is stubbed by a fake
# executable on PATH, so the real fzf is never run. Run with `make test`.

plugin="${0:A:h}/../zsh/dot-zsh/plugins/fzf.plugin.zsh"

failures=0
check() {
    local name=$1; shift
    if "$@"; then
        print "ok   - $name"
    else
        print "FAIL - $name"
        (( failures++ ))
    fi
}

stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
calls="$stub_dir/calls"

# Fake fzf: logs its arguments; `--zsh` prints a script that defines _fzf_complete
cat >"$stub_dir/fzf" <<EOF
#!/bin/sh
echo "\$*" >>"$calls"
[ "\$1" = "--zsh" ] && echo '_fzf_complete() { :; }; FZF_LOADED=1'
EOF
chmod +x "$stub_dir/fzf"

# --- fzf present ---

path=("$stub_dir" /usr/bin /bin); rehash
unset FZF_LOADED; unfunction _fzf_complete 2>/dev/null
source "$plugin"
check "sources fzf --zsh output" test "${FZF_LOADED:-}" = 1
check "calls fzf with --zsh" test "$(cat "$calls")" = "--zsh"

source "$plugin"
check "does not reload when already loaded" test "$(wc -l <"$calls" | tr -d ' ')" = 1

# --- fzf missing ---

rm -f "$calls"
path=(/usr/bin /bin); rehash
unset FZF_LOADED; unfunction _fzf_complete 2>/dev/null
source "$plugin"; rc=$?
check "returns 0 when fzf is missing" test $rc -eq 0
check "loads nothing when fzf is missing" test -z "${FZF_LOADED:-}"
check "never calls fzf when missing" test ! -e "$calls"

(( failures == 0 )) || { print "$failures test(s) failed"; exit 1; }
