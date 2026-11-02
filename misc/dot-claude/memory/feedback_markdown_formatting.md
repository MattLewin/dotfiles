---
name: feedback-markdown-formatting
description: In repos with no Markdown formatter of their own, format edited .md files with prettier --write and check them with markdownlint-cli2, instead of hand-formatting
type: feedback
---

After editing a Markdown file in a repo that has no Markdown formatter of its own, run `prettier --write <file>` via Bash to format it (table column alignment, list and emphasis markers, blank lines, escaping) instead of aligning tables or fixing Markdown formatting by hand. Then run `markdownlint-cli2 <file>` (no `--fix`) to check for problems Prettier doesn't handle, and fix real structural ones by hand. Where the repo already formats Markdown (e.g. Prettier or markdownlint in pre-commit, or a formatter config file), leave formatting to that tool.

**Why:** Prettier rewrites the whole file into one consistent style. `markdownlint-cli2 --fix` only fixes violations of its auto-fixable rules, and with the default MD060 `style: any` it never aligns tables, so it is a checker, not a formatter. Hand-formatting burns tokens on something a tool does deterministically. A second formatter in a repo that already has one would fight it.

**How to apply:**
- After any Edit/Write to a `.md` file in such a repo: `prettier --write <path>`, then `markdownlint-cli2 <path>`.
- Ignore MD013 (line length): Prettier preserves prose line breaks, so long prose lines are expected.
- If `prettier` or `markdownlint-cli2` is not on PATH, say so instead of installing it or falling back to `npx`. The user installs tools with mise (`mise use -g npm:prettier`).
