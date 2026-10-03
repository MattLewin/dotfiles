---
name: feedback-test-coverage
description: Any code change (not pattern-file/data changes) must ship with test coverage
metadata:
  type: feedback
---

Every code change I make must be covered by test cases, added in the same turn as the change, not left for later or offered as optional.

**Why:** The user treats test coverage as part of finishing a change, not a follow-up to offer afterwards.

**How to apply:**
- When editing or adding a function/module in a real codebase, write or extend tests in the same response, following the repo's existing test conventions (file location, fixture/helper style, naming).
- Run the test suite (or at least the relevant test file) before reporting the change done.
- This applies to actual code (Python/JS/etc.), not to data-only edits like lookup/pattern files, which aren't unit-testable the same way — verify those by running them through the code that consumes them.
- If a repo has no test scaffolding for the area touched (e.g. no pipeline-level integration tests yet), add unit-level tests for the pieces that can be tested in isolation, and say plainly what's left uncovered rather than skipping silently.
