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

## Message content

Keep the message succinct: the minimum needed to say what changed. No rationale, no
background, no verification notes, no mention of files checked and left unmodified.

Corrected 2026-09-18: "Your commit messages are far too chatty... Include just the
minimum to explain what changed. No rationale. No documentation. That stuff all belongs
in a README or other actual documentation."

**Why:** A commit message is a fixed record of one change. Rationale buried there is
unfindable and goes stale, and length buries the change itself in `git log`. Explanation
belongs in documentation that stays current.

**How to apply:** A subject line, using whatever convention the repo already follows. A
body only when the subject cannot carry what changed on its own, and then as a terse list
of changes rather than prose. If rationale is worth preserving, put it in the README or
CLAUDE.md as part of the same commit, and say it to the user in chat.

## Attribution

Add the `Co-Authored-By` trailer only when the message itself is at least two lines (subject plus body). A subject-only commit gets no trailer.

Corrected 2026-09-22: user had a one-line commit amended to drop the trailer, then clarified the trailer is fine on multi-line messages.

**Why:** On a one-line commit the trailer outweighs the message itself.

**How to apply:** Count only the message's own lines, not the trailer. When amending to remove a trailer, touch only the commit the user names.
