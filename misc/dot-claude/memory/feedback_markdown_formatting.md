After editing a Markdown file, run `prettier --write <file>`, then `markdownlint-cli2 <file>` (no `--fix`), and fix any real structural problems it reports by hand. Don't hand-format tables, lists or spacing. Where the repo already has its own Markdown formatter (e.g. Prettier in pre-commit, or a Prettier config file), leave formatting to it.

**Why:** Prettier rewrites the whole file into one consistent style. `markdownlint-cli2 --fix` only fixes its auto-fixable rules and never aligns tables (default MD060 `style: any`), so it is a checker, not a formatter. Hand-formatting burns tokens on deterministic work, and a second formatter would fight the repo's own.

**How to apply:**

- Ignore MD013 (line length): Prettier preserves prose line breaks, so long lines are expected.
- If `prettier` or `markdownlint-cli2` isn't on PATH, say so; don't install it or fall back to `npx`. The user installs them with mise (`mise use -g npm:prettier`).
