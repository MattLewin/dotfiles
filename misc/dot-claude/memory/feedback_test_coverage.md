Every code change must ship with tests in the same turn, not as a follow-up or an option.

**Why:** The user treats test coverage as part of finishing a change.

**How to apply:**

- Write or extend tests following the repo's conventions (location, fixtures, naming).
- Run the relevant tests before reporting the change done.
- Data-only edits (lookup or pattern files) aren't unit-testable; verify them by running them through the code that consumes them.
- If the touched area has no test scaffolding, test the pieces that can be tested in isolation, and say plainly what's left uncovered.
