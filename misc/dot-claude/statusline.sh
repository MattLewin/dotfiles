#!/bin/bash
# ~/.claude/statusline.sh — caveman badge + model + context % + cost

JSON=$(cat)

STARSHIP=""
if command -v starship >/dev/null 2>&1; then
  STARSHIP=$(printf '%s' "$JSON" | starship statusline claude-code --profile claude-code 2>/dev/null)
fi

STATS=$(printf '%s' "$JSON" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    model = d.get("model", {}).get("display_name", "")
    if model.startswith("claude-"):
        model = model[7:]
    used = d.get("context_window", {}).get("total_input_tokens", 0)
    total = d.get("context_window", {}).get("context_window_size", 0)
    cost = d.get("cost", {}).get("total_cost_usd", 0)
    pct = int(used / total * 100) if total > 0 else 0
    if pct >= 75:
        cc = "\033[38;5;196m"
    elif pct >= 50:
        cc = "\033[38;5;220m"
    else:
        cc = "\033[38;5;71m"
    reset = "\033[0m"
    dim = "\033[38;5;244m"
    parts = []
    if model:
        parts.append(dim + model + reset)
    if total > 0:
        parts.append(cc + "ctx:" + str(pct) + "%" + reset)
    if cost > 0:
        parts.append(dim + "$" + f"{cost:.4f}" + reset)
    print(" | ".join(parts), end="")
except:
    pass
')

CAVEMAN=$(bash "/Users/matt/.claude/plugins/cache/caveman/caveman/25d22f864ad6/src/hooks/caveman-statusline.sh")

LINE2=""
if [ -n "$CAVEMAN" ] && [ -n "$STATS" ]; then
  LINE2=$(printf '%s  %s' "$CAVEMAN" "$STATS")
elif [ -n "$CAVEMAN" ]; then
  LINE2="$CAVEMAN"
elif [ -n "$STATS" ]; then
  LINE2="$STATS"
fi

if [ -n "$STARSHIP" ] && [ -n "$LINE2" ]; then
  printf '%s\n%s' "$STARSHIP" "$LINE2"
elif [ -n "$STARSHIP" ]; then
  printf '%s' "$STARSHIP"
else
  printf '%s' "$LINE2"
fi
