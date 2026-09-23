#!/usr/bin/env bash
# PreToolUse(Bash): block bare pip/pipx (use uv) and bare find (aliased in zsh).
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# One command segment per line, leading whitespace and wrapper words stripped.
segments=$(printf '%s\n' "$cmd" | tr ';&|(){}' '\n\n\n\n\n\n\n' \
  | sed -E 's/^[[:space:]!$]*//; s/^((sudo|time|exec|nohup|xargs)( +-[^ ]+)* +)+//')

if printf '%s\n' "$segments" | grep -Eq '^([^ ]*/)?(pip[0-9.]*|pipx)( |$)|^([^ ]*/)?python[0-9.]*( +-[^ ]+)* +-m +pip( |$)'; then
  echo "Blocked: use uv instead of pip/pipx (uv add, uv sync, uv pip, uv tool install, uvx)." >&2
  exit 2
fi

if printf '%s\n' "$segments" | grep -Eq '^find( |$)'; then
  echo "Blocked: find is aliased in zsh; use /usr/bin/find." >&2
  exit 2
fi

exit 0
