---
name: feedback-uv
description: Use uv instead of pip or pipx in every project; uv's own subcommands (incl. `uv pip`) are fine
metadata:
  type: feedback
---

Never run standalone `pip`, `pip3`, `python -m pip`, or `pipx`. Use the uv equivalent: `uv add` / `uv sync` / `uv pip` for pip, `uv tool install` / `uvx` for pipx. Run project tools with `uv run <cmd>`.

**Why:** The user has replaced pip and pipx with uv throughout their toolchain.

**How to apply:** Pick the uv form before running any install or tool command. A global PreToolUse hook (`~/.claude/hooks/block-bash.sh`) blocks the bare commands, so a slip costs a failed call. The hook splits commands on `; & | ( ) { }` and newlines, so a heredoc line that starts with `pip` or `find` also trips it; write such text with the Write tool instead.
