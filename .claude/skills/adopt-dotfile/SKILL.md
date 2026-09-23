---
name: adopt-dotfile
description: Move an existing file or directory from $HOME into the right stow package and link it back.
disable-model-invocation: true
argument-hint: <path under $HOME>
---

# Adopt a file from $HOME into the dotfiles repo

Target: `$ARGUMENTS`

Stop and report at the first failed check. Do not commit.

## 1. Check the target

- It must exist under `$HOME` and must not already resolve into this repo
  (`realpath` it).
- Scan it for secrets: `gitleaks dir --no-banner <path>`. If gitleaks finds
  anything, stop. Credentials belong in `~/.config/dotfiles/api_tokens.zsh` or a
  local override file, never in the repo (see CLAUDE.md, "Local Overrides").
- If it is a directory, list its contents. Point out caches, logs, history files
  and machine-specific state, and ask the user which parts to adopt.

## 2. Choose the package and path

- Package: `zsh`, `bash`, `git` or `tmux` for those tools, `macOS` for
  macOS-only files, otherwise `misc`. Look at where similar files already live.
  Ask the user if the choice is unclear.
- Repo path: the path relative to `$HOME`, with the leading `.` of every
  component replaced by `dot-`. For example, `~/.config/foo/.bar` becomes
  `misc/dot-config/foo/dot-bar`.
- Stow ignores `scripts`, `.DS_Store`, `*.example`, `README.*` and `LICENSE.*`
  (Makefile `STOW_IGNORE` and stow defaults). Warn if the name matches one.

## 3. Move, keeping directories unfolded

1. Record every directory inside the target: `find <path> -type d`.
2. `mkdir -p` the destination's parent in the repo, then `mv` the target there.
3. `mkdir -p` every recorded directory back under `$HOME`. Stow folds a
   directory into one symlink when the target directory does not exist, and a
   folded directory lets tools write into the working tree (CLAUDE.md,
   "Directory Folding").

## 4. Dry run, then stow

```sh
stow -n --verbose=1 --restow --dotfiles --target "$HOME/" \
  --ignore='^scripts$' --ignore='\.DS_Store$' --ignore='\.example$' <package>
```

The output must show a `LINK` line for each adopted file, no conflicts, and no
`LINK` for a directory. On failure, `mv` the files back to their original
location and stop.

Then run `make dotfiles` and confirm with `ls -l` that each target is a symlink
into the repo.

## 5. Lint coverage

- A new sh, bash or zsh script without a `.zsh` extension must be added to
  `SH_SCRIPTS`, `BASH_SCRIPTS` or `ZSH_FILES` in the Makefile. Add a zsh one to
  the matching list in `.claude/hooks/lint-edited.sh` too.
- If the adopted directory will receive runtime files, add them to `.gitignore`.
- Run `make lint`, then show `git status --short`.
