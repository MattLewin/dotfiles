---
name: Minimize subagent spawning
description: User prefers direct tool use over spawning subagents to reduce token usage
type: feedback
---

Minimize subagent spawning, and use Haiku for lightweight subagents.

**Why:** Subagents multiply token usage significantly — 76% of observed usage was attributed to subagent-heavy patterns. The user wants to reduce this cost.

**How to apply:**
- Default to direct tool calls (Read, Bash grep/find) for codebase exploration instead of spawning subagents.
- Only spawn a subagent when the task is genuinely too broad or complex to handle inline.
- When spawning a lightweight subagent (Explore searches, simple lookups, narrow research), set `model: "haiku"`.
- Reserve Sonnet/Opus subagents for tasks requiring real reasoning, code generation, or complex judgment.
- **Before every Agent tool call**, emit a highly visible text line in this exact format so the user can see which model is being used:
  `**** SPAWNING SUBAGENT: <type> — MODEL: <model> ****`
