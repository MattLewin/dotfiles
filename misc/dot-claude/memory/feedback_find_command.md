---
name: feedback-find-command
description: `find` is aliased in the user's zsh; always use /usr/bin/find
metadata:
  type: feedback
---

Always use `/usr/bin/find` instead of `find` in Bash commands, in every project.

**Why:** The user's zsh aliases `find` to a different command, causing unexpected behavior.

**How to apply:** Write `/usr/bin/find` whenever a command needs find. A global PreToolUse hook (`~/.claude/hooks/block-bash.sh`) blocks bare `find`. See [[feedback-uv]] for the hook's heredoc false-positive caveat.
