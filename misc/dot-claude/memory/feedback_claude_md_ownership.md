---
name: feedback-claude-md-ownership
description: "CLAUDE.md and other Claude-facing instruction files are Claude's to maintain — fix problems directly, don't flag and wait"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3c47ff0b-4455-4eaa-bdae-461ecef17126
  modified: 2026-09-06T23:58:02.157Z
---

CLAUDE.md (and other Claude-facing guidance/instruction files) belong to Claude, not the user. When Claude spots a problem in one — stale path, wrong code, outdated instruction, ambiguity — fix it directly.

**Why:** The user does not want to review or approve edits to files that exist for Claude's benefit. Flagging a defect and waiting for permission wastes a turn on something that was never the user's call.

**How to apply:**
- Found a bug/staleness/ambiguity in CLAUDE.md or similar → just fix it, mention the fix briefly.
- Only surface it for a decision when the fix genuinely requires user input (a factual answer Claude can't verify, a judgment call about intent).
- Applies across all projects, not just the one where it came up.
