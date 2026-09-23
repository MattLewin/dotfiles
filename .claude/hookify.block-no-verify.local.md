---
name: block-no-verify
enabled: true
event: bash
pattern: git\s.*(--no-verify|-c\s*core\.hooksPath)|git\s+commit(\s+--?[a-zA-Z-]+)*\s+-[a-zA-Z]*n[a-zA-Z]*\b
action: block
---

# Commit hook bypass blocked

`githooks/pre-commit` runs the gitleaks secret scan and `make lint`. Skipping it
can let a credential into history. Fix the failing check, or ask the user to run
the commit themselves if the bypass is intended.
