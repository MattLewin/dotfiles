#!/usr/bin/env zsh -f
# Tests for the `git ignored` alias in git/dot-gitconfig. Runs against a
# throwaway repo with the tracked gitconfig as the only global config.
# Run with `make test`.

export GIT_CONFIG_GLOBAL="${0:A:h}/../git/dot-gitconfig"
export GIT_CONFIG_NOSYSTEM=1

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

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT
cd "$repo"
git init -q
# Keep the user's global excludesFile out of the results
git config core.excludesFile /dev/null

# --- nothing ignored ---

print 'a' >kept.txt
check "prints nothing when nothing is ignored" test -z "$(git ignored)"

# --- untracked ignored files ---

print -l '*.log' 'build/' 'cache/' >.gitignore
print 'x' >debug.log
mkdir -p build/deep && print 'x' >build/deep/out.o
mkdir -p sub && print 'x' >sub/inner.log
# An empty ignored directory inside an otherwise empty one
mkdir -p holder/cache
# A directory holding both ignored and unignored files
mkdir -p mixed && print 'x' >mixed/a.log && print 'x' >mixed/keep.txt
print 'x' >'with space.log'

out=$(git ignored)
check "lists an ignored file" grep -qx 'debug.log' <<<"$out"
check "lists an ignored file in a subdirectory" grep -qx 'sub/inner.log' <<<"$out"
check "collapses an ignored directory to one line" grep -qx 'build/' <<<"$out"
check "does not list files inside an ignored directory" test -z "$(grep 'out.o' <<<"$out")"
check "does not list an empty ignored directory" test -z "$(grep 'cache' <<<"$out")"
check "does not list a parent holding only empty ignored dirs" \
    test -z "$(grep 'holder' <<<"$out")"
check "lists an ignored file in a mixed directory" grep -qx 'mixed/a.log' <<<"$out"
check "does not list a mixed directory itself" test -z "$(grep -x 'mixed/' <<<"$out")"
check "lists a file name with a space unquoted" grep -qx 'with space.log' <<<"$out"
check "does not list unignored files" test -z "$(grep 'kept.txt' <<<"$out")"
check "omits the tracked section when empty" test -z "$(grep 'Tracked' <<<"$out")"

# --- tracked files that match ignore rules ---

print 'x' >tracked.log
git add -f tracked.log kept.txt .gitignore

out=$(git ignored)
check "prints the tracked section header" grep -qx 'Tracked, but matching ignore rules:' <<<"$out"
check "lists a tracked file matching a rule" grep -qx 'tracked.log' <<<"$out"
check "lists the tracked file after the header" \
    test "$(sed -n '/^Tracked/,$p' <<<"$out" | grep -cx 'tracked.log')" = 1

check "prints no color codes when piped" test -z "$(grep $'\e' <<<"$out")"

out=$(git -c color.ignored=always ignored)
check "colors the header when color is forced" \
    grep -q $'^\e\\[1;33mTracked, but matching ignore rules:\e\\[m$' <<<"$out"
check "leaves file names uncolored" grep -qx 'tracked.log' <<<"$out"

out=$(git -c color.ignored=always -c color.ignored.header=cyan ignored)
check "honors a color.ignored.header override" \
    grep -q $'^\e\\[36mTracked' <<<"$out"

out=$(git -c color.ui=never ignored)
check "honors color.ui=never" test -z "$(grep $'\e' <<<"$out")"

# --- run from a subdirectory ---

check "reports repo-root paths from a subdirectory" \
    grep -qx 'debug.log' <<<"$(cd sub && git ignored)"
check "exits 0" sh -c 'git ignored >/dev/null'

(( failures == 0 )) || { print "$failures test(s) failed"; exit 1; }
