#!/bin/bash
# ~/.claude/statusline.sh — caveman badge + model + output style + context % + cost

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
    style = d.get("output_style", {}).get("name", "")
    parts = []
    if model:
        parts.append(dim + model + reset)
    if style:
        sc = dim if style.lower() == "default" else "\033[38;5;44m"
        parts.append(sc + "style:" + style + reset)
    if total > 0:
        parts.append(cc + "ctx:" + str(pct) + "%" + reset)
    if cost > 0:
        parts.append(dim + "$" + f"{cost:.4f}" + reset)
    print(" | ".join(parts), end="")
except:
    pass
')

CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# Disabling the caveman plugin leaves its cache and mode flag behind, so the
# hook would still render a badge. Run it only while the plugin is enabled,
# reading settings in Claude Code's order: a later file overrides an earlier one.
CAVEMAN_ENABLED=$(printf '%s' "$JSON" | CFG="$CFG" python3 -c '
import json, os, sys
try:
    proj = json.load(sys.stdin).get("workspace", {}).get("project_dir", "")
except Exception:
    proj = ""
cfg = os.environ["CFG"]
paths = [os.path.join(cfg, "settings.json"), os.path.join(cfg, "settings.local.json")]
if proj:
    paths += [os.path.join(proj, ".claude", f) for f in ("settings.json", "settings.local.json")]
on = False
for p in paths:
    try:
        with open(p) as fh:
            v = json.load(fh).get("enabledPlugins", {}).get("caveman@caveman")
    except Exception:
        continue
    if isinstance(v, bool):
        on = v
print("1" if on else "", end="")
')

# The caveman plugin's statusline hook lives under a content-hashed directory
# that changes whenever the plugin updates, and more than one version can be
# cached at once. Resolve it at runtime, newest first, and skip it if absent.
# It reads session_id from the session JSON to pick this window's mode.
CAVEMAN=""
if [ -n "$CAVEMAN_ENABLED" ]; then
  caveman_hook=$(
    find "${CFG}/plugins/cache/caveman/caveman" \
      -name caveman-statusline.sh -type f -print0 2>/dev/null |
      xargs -0 ls -t 2>/dev/null | head -1
  )
  if [ -n "$caveman_hook" ] && [ -r "$caveman_hook" ]; then
    CAVEMAN=$(printf '%s' "$JSON" | bash "$caveman_hook" 2>/dev/null)
  fi
fi

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
