---
name: brew-sync
description: Add installed Homebrew formulas and casks that are missing from the tracked Brewfile.
disable-model-invocation: true
allowed-tools: Bash(brew leaves *) Bash(brew list *) Bash(brew info *) Read Edit
---

# Sync the Brewfile with installed packages

The Brewfile is `misc/dot-config/homebrew/Brewfile`. It holds a `brew` block and
then a `cask` block. Each block is sorted alphabetically, and every entry uses
single quotes, for example `brew 'jq'`. There are no comments and no other entry
types.

1. List what the user installed on purpose. Use `brew leaves`, not
   `brew bundle dump`, which also lists dependencies:

   ```sh
   { brew leaves --installed-on-request | sed 's/^/brew /'
     brew list --cask -1 | sed 's/^/cask /'; } | sort -u
   ```

2. List what the Brewfile tracks:

   ```sh
   sed -nE "s/^(brew|cask) '([^']+)'.*/\1 \2/p" misc/dot-config/homebrew/Brewfile | sort -u
   ```

3. Compare the two lists with `comm -3`. Before reporting, resolve aliases: a
   tracked name can be an alias of an installed one (Brewfile `delta` is
   formula `git-delta`). `brew info --json=v2 <name> | jq -r '.formulae[0].name'`
   gives the canonical name. Show the user two groups:
   - **Installed but not tracked:** candidates to add.
   - **Tracked but missing:** only entries absent from `brew list --formula -1`
     and `brew list --cask -1`. A tracked formula that is installed as a
     dependency is not missing. Report only. Never remove entries; the file is
     shared across machines.

4. Ask the user which candidates to add. Some packages are installed ad hoc on
   purpose.

5. Insert each chosen entry into its block at its sorted position, in the
   existing single-quote form. Do not reorder or reformat other lines.

6. Show `git diff misc/dot-config/homebrew/Brewfile`. Do not commit.
