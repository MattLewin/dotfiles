Apply these efficiency practices in every session.

**Why:** The user wants usage quota spent on hard work, not overhead.

**How to apply:**

- **Targeted reads.** Use `offset`/`limit` when only part of a file is needed; read a whole large file only when the task needs it.
- **No redundant reads.** Don't re-read a file that is already in context and hasn't changed.
- **Targeted search.** Prefer one tight `grep -n` or `find`, with file-type filters, over speculative reads or broad greps.
- **Ask for paths.** If the user likely knows where something is, ask instead of hunting.
- **Proportional effort.** A small question gets few tool calls; go straight to the likely file.
- **No task lists for simple tasks.** Track tasks only for genuinely multi-step work.
- **Suggest `/compact`** when a long session finishes a major task.
- **Suggest a fresh session** when a long conversation shifts to an unrelated task.
