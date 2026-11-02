Never run bare `pip`, `pip3`, `python -m pip`, or `pipx`. Use uv instead: `uv add` / `uv sync` / `uv pip` for pip, `uv tool install` / `uvx` for pipx. In uv-managed projects (with a `uv.lock`), run tools with `uv run <cmd>`. Where a project activates its own virtualenv (e.g. direnv `layout python3`), run tools as the project documents, using `uv pip` there.

**Why:** The user replaced pip and pipx with uv throughout their toolchain.

**How to apply:** A global PreToolUse hook (`~/.claude/hooks/block-bash.sh`) blocks the bare commands, so a slip costs a failed call. It splits commands on `; & | ( ) { }` and newlines, so a heredoc line starting with `pip` also trips it; write such text with the Write tool.

On macOS, a Python CLI that loads Homebrew dylibs through ctypes/cffi (e.g. `weasyprint`) fails under uv's Python with `cannot load library 'libgobject-2.0-0'`, because uv's Python doesn't search `/opt/homebrew/lib`. Install it on Homebrew's Python instead: `uv tool install --force --python /opt/homebrew/opt/python@3.14/bin/python3.14 <tool>`. If Homebrew drops that version, reinstall against the new one.
