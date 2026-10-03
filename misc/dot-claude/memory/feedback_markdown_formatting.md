---
name: feedback-markdown-formatting
description: In repos with no Markdown formatter of their own, use markdownlint-cli2 --fix on edited .md files instead of hand-formatting tables/markdown
type: feedback
---

After editing a Markdown file in a repo that has no Markdown formatter of its own, run `markdownlint-cli2 --fix <file>` via Bash to apply formatting (table column alignment, etc.) instead of manually aligning tables or other MD formatting by hand. Where the repo already formats Markdown (e.g. Prettier or markdownlint in pre-commit, or a formatter config file), leave formatting to that tool.

**Why:** User's VSCode has a markdownlint extension that auto-formats on save (table alignment etc.), and expects that same aligned-column result everywhere — all sessions, all platforms. Hand-formatting tables burns tokens for no reason when a CLI tool does it deterministically. `markdownlint-cli2` is the CLI engine behind that extension, so running it gives identical output to what the extension would produce. A second formatter in a repo that already has one would fight it.

**How to apply:** Any time editing/writing a `.md` file with tables in such a repo, after the Edit/Write run `markdownlint-cli2 --fix <path>` then Read the file to confirm result — don't manually align table pipes/columns or fuss over MD formatting by hand. If `markdownlint-cli2` is missing, say so instead of installing it.
