---
name: Commit workflow
description: User handles git commands; Claude outputs the commit message and exact command to run
type: feedback
---

Only output a suggested commit message when the user explicitly asks for one. Do not offer it automatically at the end of a task. Do not run git commands unless the user explicitly asks.

**Why:** User is comfortable with git CLI and controls when/whether to commit. Auto-suggesting a commit after every task was unwanted noise — corrected 2026-08-22 after previously being asked to always suggest one.

**How to apply:** When the user does ask for a commit message, provide:
1. A concise commit message (same quality standard as before)
2. The exact shell command(s) to stage and commit the relevant files

Example format:
> Suggested commit:
> ```
> git add path/to/file && git commit -m "Your message here"
> ```
