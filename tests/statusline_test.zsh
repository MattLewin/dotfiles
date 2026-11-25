#!/usr/bin/env zsh -f
# Tests for the caveman badge in misc/dot-claude/statusline.sh. Runs against a
# throwaway CLAUDE_CONFIG_DIR holding a stub caveman hook, so the real plugin
# and settings are never read. Run with `make test`.

script="${0:A:h}/../misc/dot-claude/statusline.sh"

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

cfg=$(mktemp -d)
proj=$(mktemp -d)
trap 'rm -rf "$cfg" "$proj"' EXIT
export CLAUDE_CONFIG_DIR=$cfg

# The stub prints a badge carrying the session_id it was given on stdin
hook_dir="$cfg/plugins/cache/caveman/caveman/9.9.9/src/hooks"
mkdir -p "$hook_dir" "$proj/.claude"
cat >"$hook_dir/caveman-statusline.sh" <<'EOF'
id=$(grep -o '"session_id": *"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
printf '[CAVEMAN:%s]' "$id"
EOF

json='{"session_id": "abc123", "model": {"display_name": "Opus"}, "workspace": {"project_dir": "'$proj'"}}'
run() { bash "$script" <<<"$json" }
plugin() { print "{\"enabledPlugins\": {\"caveman@caveman\": $2}}" >"$1" }

check "hides the badge when no settings exist" test -z "$(run | grep CAVEMAN)"

plugin "$cfg/settings.json" false
check "hides the badge when the plugin is disabled" test -z "$(run | grep CAVEMAN)"

plugin "$cfg/settings.json" true
check "shows the badge when the plugin is enabled" grep -q 'CAVEMAN' <<<"$(run)"
check "passes the session JSON to the hook" grep -q 'CAVEMAN:abc123' <<<"$(run)"
check "keeps the model stats beside the badge" grep -q 'Opus' <<<"$(run)"

plugin "$cfg/settings.local.json" false
check "local settings override user settings" test -z "$(run | grep CAVEMAN)"

plugin "$proj/.claude/settings.json" true
check "project settings override local settings" grep -q 'CAVEMAN' <<<"$(run)"

plugin "$proj/.claude/settings.local.json" false
check "project local settings override project settings" \
    test -z "$(run | grep CAVEMAN)"

rm "$proj/.claude/settings.local.json" "$proj/.claude/settings.json"
print '{not json' >"$cfg/settings.local.json"
check "skips an unreadable settings file" grep -q 'CAVEMAN' <<<"$(run)"

rm -rf "$cfg/plugins"
check "hides the badge when the hook is not cached" test -z "$(run | grep CAVEMAN)"

(( failures == 0 ))
