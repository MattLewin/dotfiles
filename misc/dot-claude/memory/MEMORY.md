# Memory Index

- [Minimize subagent spawning](feedback_subagent_usage.md) — prefer direct Bash/Read tool calls over spawning agents; reduces token usage
- [General efficiency practices](feedback_efficiency.md) — targeted reads, no redundant reads, grep over exploration, suggest /compact, proportional tool use
- [Commit workflow](feedback_commits.md) — output commit message + exact git command for user to run; do not run git commands unless asked
- [Response style](feedback_response_style.md) — keep proposals/reasoning clear; cut trailing summaries and narration of visible changes
- [Test coverage required](feedback_test_coverage.md) — code changes must ship with tests in the same turn, not as a follow-up
- [Markdown formatting](feedback_markdown_formatting.md) — run `markdownlint-cli2 --fix` on edited .md files instead of hand-aligning tables
- [CLAUDE.md ownership](feedback_claude_md_ownership.md) — CLAUDE.md and similar Claude-facing files are Claude's to maintain; fix defects directly, don't flag and wait
- [Use uv, not pip/pipx](feedback_uv.md) — never bare pip/pipx; `uv pip`, `uv tool`, `uvx` OK; hook-enforced
