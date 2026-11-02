# Memory Index

- [Minimize subagent spawning](feedback_subagent_usage.md) — direct tool calls over subagents; Haiku for lightweight ones
- [General efficiency practices](feedback_efficiency.md) — targeted reads and searches, no redundant reads, proportional tool use, suggest /compact
- [Commit workflow](feedback_commits.md) — no git commands or commit messages unless asked; terse messages; trailer only with a body
- [Response style](feedback_response_style.md) — explain before acting; no end-of-task recaps; brief status on long runs
- [Test coverage required](feedback_test_coverage.md) — code changes ship with tests in the same turn
- [Markdown formatting](feedback_markdown_formatting.md) — run `prettier --write` then `markdownlint-cli2` (no `--fix`) on edited .md files unless the repo has its own formatter
- [CLAUDE.md ownership](feedback_claude_md_ownership.md) — Claude-facing files are Claude's to maintain; fix defects directly
- [Use uv, not pip/pipx](feedback_uv.md) — never bare pip/pipx; `uv pip`, `uv tool`, `uvx` instead; hook-enforced
