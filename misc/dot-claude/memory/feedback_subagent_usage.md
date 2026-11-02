Minimize subagent spawning, and use Haiku for lightweight subagents.

**Why:** Subagents multiply token usage; 76% of observed usage came from subagent-heavy patterns.

**How to apply:**

- Default to direct tool calls (Read, grep, find) for exploration. Spawn a subagent only when the task is genuinely too broad or complex to handle inline.
- Set `model: "haiku"` for lightweight subagents (Explore searches, simple lookups, narrow research). Reserve Sonnet/Opus for real reasoning, code generation, or complex judgment.
- **Before every Agent tool call**, emit this line exactly, so the user sees the model:
  `**** SPAWNING SUBAGENT: <type> — MODEL: <model> ****`
