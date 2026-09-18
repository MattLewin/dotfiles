---
name: General efficiency practices
description: Standing guidance to minimize token/resource usage across all sessions
type: feedback
---

Apply these efficiency practices automatically in every session.

**Why:** User wants to preserve usage quota for hard work, not burn it on overhead.

**How to apply:**

- **Targeted file reads.** Use `offset`/`limit` when only part of a file is needed. Never read a whole file just to check one function or one section.
- **No redundant reads.** If a file was already read earlier in the session, don't read it again — work from what's already in context.
- **Prefer grep/find over broad exploration.** A single `grep -n` or `find` call is almost always cheaper than reading multiple files speculatively.
- **Ask for file paths rather than searching.** If the user likely knows where something is, ask before spending tool calls hunting for it.
- **Suggest `/compact` proactively.** When a session has gotten long and a major task just completed, suggest the user run `/compact` before starting the next task.
- **Don't spin up research machinery for simple questions.** If the answer is likely a one-liner or in one file, go there directly instead of doing broad exploration first.
- **Avoid reading or summarizing large code blocks unnecessarily.** Only pull large files into context when actually needed for the task at hand.
- **Keep tool calls proportional to task complexity.** A small question gets a small number of tool calls. Don't over-investigate.
- **Targeted grep patterns.** Use file-type filters and tight patterns to keep result sizes small. Broad greps produce large results that bloat context.
- **Skip TodoWrite for simple tasks.** Only use it for genuinely multi-step tasks. One or two steps don't need a task list.
- **Suggest fresh sessions when topics drift.** If the conversation has been long and shifts to an unrelated task, proactively suggest the user start a new session to keep context lean.
