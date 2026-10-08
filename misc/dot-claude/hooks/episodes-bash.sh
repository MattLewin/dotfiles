#!/usr/bin/env bash
# PreToolUse(Bash) for the Episodes project (registered in
# /Volumes/Sharing/Episodes/.claude/settings.local.json). Hoos works in manual
# permission mode and these shell forms always raise a prompt, so refuse them
# and make Claude rewrite the call instead of making him click through.
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# Harmless lookalikes: stderr redirects and the arrows in pattern files.
plain=$cmd
for s in '2>/dev/null' '2>&1' '=>' '->'; do plain=${plain//"$s"/}; done

# One line per pipe segment, leading whitespace stripped.
segments=$(printf '%s\n' "$cmd" | tr '|' '\n' | sed -E 's/^[[:space:]]+//')

reason=
if [[ $cmd == *$'\n'* ]]; then
  reason="multi-line command or heredoc"
elif [[ $plain == *'&&'* || $plain == *'||'* || $plain == *';'* ]]; then
  reason="chained command (&&, ||, ;, or a loop)"
elif [[ $cmd == *'<<'* ]]; then
  reason="heredoc"
elif [[ $cmd == *'$('* || $cmd == *'`'* ]]; then
  reason="command substitution"
elif [[ $plain == *'>'* ]]; then
  reason="output redirect"
elif printf '%s\n' "$segments" | grep -Eq '^(mv|sed( +-[^ ]*)* +-i)( |$)|^sed +-i'; then
  reason="mv or sed -i (use Edit or Write)"
elif printf '%s\n' "$segments" | grep -E '^python3( |$)' | grep -Evq 'srt_check\.py|/private/tmp/claude-501/'; then
  reason="python3 other than srt_check.py"
fi

if [ -n "$reason" ]; then
  echo "Blocked in Episodes: $reason always prompts Hoos. Use Read/Edit/Write for files, or one plain allowlisted command (see \"Tool use\" in Episodes/CLAUDE.md)." >&2
  exit 2
fi
exit 0
