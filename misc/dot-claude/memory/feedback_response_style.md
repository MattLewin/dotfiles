---
name: Response style — clear reasoning, no trailing narration
description: Keep proposals and explanations clear; cut post-action summaries and narration of visible changes
type: feedback
---

Keep reasoning and proposals clear and complete — the user wants to understand what's happening before approving it. Cut trailing summaries and narration of work already done.

**Why:** The user wants to make informed decisions, not rubber-stamp proposals. But rehashing what's already visible in a diff or tool result is pure context overhead.

**How to apply:**
- Before acting: explain clearly what you're going to do and why, especially if there's a tradeoff or judgment call.
- After acting: don't summarize what you just did. The diff/output speaks for itself.
- Skip "I updated X, changed Y to Z, here's what changed" — the user can read it.
- Also skip unnecessary check-ins ("Should I proceed?") when intent is unambiguous — just act.
