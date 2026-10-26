#!/usr/bin/env zsh -f
# Tests for _update_step and update-all in zsh/dot-zsh/aliases.zsh.
# The real updaters are stubbed, so nothing is upgraded. Run with `make test`.

export TERM=${TERM:-xterm-256color}
source "${0:A:h}/../zsh/dot-zsh/aliases.zsh"

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

# --- _update_step ---

out=$(_update_step "STEP TITLE" true); rc=$?
check "step returns 0 when the command succeeds" test $rc -eq 0
check "step prints its title" test "${out#*STEP TITLE}" != "$out"

out=$(_update_step "STEP TITLE" false); rc=$?
check "step returns 1 when the command fails" test $rc -eq 1
check "step names the failed command" test "${out#*\*\*\* \'false\' failed!}" != "$out"

out=$(_update_step "STEP TITLE" print -r -- "a b" c)
check "step passes arguments through intact" test "${out#*a b c}" != "$out"

# --- update-all ---

stub_all() {
    claude() { print RAN-claude; }
    antidote() { print RAN-antidote; }
    mise() { print RAN-mise; }
    uv() { print "RAN-uv-$1"; }
    brew() { print RAN-brew; }
    nvim() { print RAN-nvim; }
}

stub_all
out=$(update-all); rc=$?
check "update-all returns 0 when every step succeeds" test $rc -eq 0
for step in claude antidote mise uv-python uv-tool brew nvim; do
    check "update-all runs $step" test "${out#*RAN-$step}" != "$out"
done
check "update-all reports completion" test "${out#*All updates complete.}" != "$out"

stub_all
mise() { return 1; }
out=$(update-all); rc=$?
check "update-all returns 1 when a step fails" test $rc -eq 1
check "update-all stops after the failed step" test "${out#*RAN-uv}" = "$out"
check "update-all skips the completion message on failure" test "${out#*All updates complete.}" = "$out"

(( failures == 0 )) || { print "$failures test(s) failed"; exit 1; }
