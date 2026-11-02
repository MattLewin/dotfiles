---
name: feedback-uv
description: Use uv instead of pip or pipx in every project; uv's own subcommands (incl. `uv pip`) are fine
metadata:
  type: feedback
---

Never run standalone `pip`, `pip3`, `python -m pip`, or `pipx`. Use the uv equivalent: `uv add` / `uv sync` / `uv pip` for pip, `uv tool install` / `uvx` for pipx. In uv-managed projects (those with a `uv.lock`), run project tools with `uv run <cmd>`. Where a project activates its own virtualenv (e.g. direnv `layout python3`), run tools the way the project documents, and use `uv pip` in place of `pip` there.

**Why:** The user has replaced pip and pipx with uv throughout their toolchain.

**How to apply:** Pick the uv form before running any install or tool command. A global PreToolUse hook (`~/.claude/hooks/block-bash.sh`) blocks the bare commands, so a slip costs a failed call. The hook splits commands on `; & | ( ) { }` and newlines, so a heredoc line that starts with `pip` also trips it; write such text with the Write tool instead.

On macOS, a Python CLI that loads Homebrew dylibs through ctypes/cffi (e.g. `weasyprint`, which needs Pango/GObject) fails under uv's own Python with `cannot load library 'libgobject-2.0-0'`, because uv's Python does not search `/opt/homebrew/lib`. Install such a tool on Homebrew's Python instead: `uv tool install --force --python /opt/homebrew/opt/python@3.14/bin/python3.14 <tool>`. If Homebrew drops that Python version, reinstall the tool against the new one.
