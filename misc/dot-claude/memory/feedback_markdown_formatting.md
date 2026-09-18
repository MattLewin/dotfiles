---
name: feedback-markdown-formatting
description: Use markdownlint-cli2 --fix on .md files instead of hand-formatting tables/markdown
type: feedback
---

After editing any Markdown file, run `markdownlint-cli2 --fix <file>` via Bash to apply formatting (table column alignment, etc.) instead of manually aligning tables or other MD formatting by hand.

**Why:** User's VSCode has a markdownlint extension that auto-formats on save (table alignment etc.), and expects that same aligned-column result everywhere — all sessions, all platforms. Hand-formatting tables burns tokens for no reason when a CLI tool does it deterministically. `markdownlint-cli2` (Node, installed globally via `npm i -g markdownlint-cli2`) is the CLI engine behind that extension, so running it gives identical output to what the extension would produce.

**How to apply:** Any time editing/writing a `.md` file with tables, after the Edit/Write run `markdownlint-cli2 --fix <path>` then Read the file to confirm result — don't manually align table pipes/columns or fuss over MD formatting by hand. If `markdownlint-cli2` is missing, install globally with `npm i -g markdownlint-cli2` rather than falling back to npx one-offs repeatedly.
