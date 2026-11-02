Don't run git commands or suggest a commit message unless the user explicitly asks.

**Why:** The user is comfortable with git and controls when and whether to commit; unprompted commit suggestions are noise.

**How to apply:** When asked for a commit message, give the message and the exact command to stage and commit:

> Suggested commit:
>
> ```
> git add path/to/file && git commit -m "Your message here"
> ```

## Message content

Say only what changed: no rationale, background, verification notes, or files checked and left unmodified. Follow the repo's subject-line convention. Add a body only when the subject can't carry the change, and then as a terse list, not prose.

Never mention documentation updates (README, CLAUDE.md, docstrings) in the message; they are assumed to accompany the change. Still stage those files.

**Why:** A commit message is a fixed record of one change. Rationale buried there is unfindable and goes stale, and length buries the change in `git log`.

**How to apply:** If rationale is worth keeping, put it in the README or CLAUDE.md in the same commit and tell the user in chat.

## Attribution

Add the `Co-Authored-By` trailer only when the message has a body. A subject-only commit gets no trailer. When amending to remove a trailer, touch only the commit the user names.

**Why:** On a one-line commit the trailer outweighs the message.
