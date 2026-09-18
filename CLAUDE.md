# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed with **GNU Stow** (symlink manager). Stow maps files with a `dot-` prefix into the home directory as `.`-prefixed symlinks (e.g., `zsh/dot-zshrc` → `~/.zshrc`).

## Key Commands

```bash
make              # Full install: Homebrew, Antidote, stow, launch agents
make dotfiles     # Re-stow all dotfiles (safe to re-run)
make bootstrap-local  # Create local override files (not in default `make`)
brew bundle       # Install Homebrew packages (single Brewfile)
make lint         # shellcheck, shfmt, zsh -n, fish -n, jq, plutil, markdownlint, stow -n
```

Stow packages: `bash`, `git`, `misc`, `tmux`, `zsh`, plus `macOS` on Darwin

## Architecture

### Naming Convention
All files managed by stow are prefixed with `dot-` (stow's `.stowrc` maps these to `.`-prefixed files in `$HOME`). The top-level directory name becomes the stow package name.

### Directory Layout
- `zsh/dot-zsh/` — Modular zsh config loaded by `.zshrc`. See `zsh/README.md` for full load order, the plugin system, and the Oh My Zsh → Antidote migration map.
  - `plugins_builder.zsh` — Dynamically builds Antidote plugin list based on installed commands
  - `config.d/darwin.zsh` — OS-specific settings, sourced by `$OS` name.
    Only `darwin.zsh` exists today; the Linux machines run fish, not zsh.
  - `aliases.zsh`, `paths.zsh`, `variables.zsh`, `fzf.zsh` — Functional modules
  - `api_tokens.zsh` — API credentials (git-ignored; template at `api_tokens.zsh.example`)
- `misc/dot-config/homebrew/Brewfile` — Single Brewfile (formulas + casks)
- `misc/dot-config/nvim/init.lua` — Neovim config (lazy.nvim plugin manager)
- `install_scripts/` — Bootstrap scripts called by Makefile targets

### Local Overrides (Not Tracked)
Machine-specific settings live outside the repo to keep it portable:

| File | Purpose |
|------|---------|
| `~/.config/dotfiles/local.zsh` | Zsh overrides, sourced last in `.zshrc` |
| `~/.gitconfig.local` | Git user identity (name/email) |

Templates exist at `misc/dot-config/dotfiles/local.zsh.example` and `git/dot-gitconfig.local.example`.

### `~/.config` and Directory Folding

`~/.config` is a real directory. Stow links each tracked file into it
individually, so untracked files there — `gh/hosts.yml`, `op/config`,
`creds/wdplay`, `1Password/` — live outside this working tree.

Stow folds a package directory into a single symlink when the target directory
does not already exist. A folded directory points at the repo, so anything a
tool writes into it lands in the working tree. `~/.zsh` is folded today, which
is why `zsh/dot-zsh/completions/` needs a `.gitignore` entry. Every directory
under `~/.config` is unfolded, and stays that way because each one already
exists. To unfold a folded directory: create it, move the package's files back
under it, and re-run `make dotfiles`.

### Platform Detection
- Makefile branches on `$(UNAME)` (Darwin vs Linux)
- Zsh branches via `zsh/dot-zsh/config.d/` directory — drop a `darwin.zsh` or `linux.zsh` file there
- macOS-only: launch agents in `launch_agents/` for SSH key management

### Zsh Plugin Management
Antidote is the plugin manager (`~/.antidote/`). The plugin list is built dynamically by `plugins_builder.zsh` — it checks for installed commands and only loads relevant plugins (e.g., aws plugin only if `aws` is in PATH). Syntax highlighting always loads last.

## Adding New Configs

1. Place files in the appropriate stow package directory with a `dot-` prefix
2. Run `make dotfiles` to re-stow
3. Add new Homebrew packages to `misc/dot-config/homebrew/Brewfile`. There is
   one Brewfile, holding both formulas and casks; there is no per-OS split.
4. Machine-specific settings belong in `~/.config/dotfiles/local.zsh`, not in the repo

## Claude Code Config (`misc/dot-claude/`)

Stowed to `~/.claude`. What is tracked and what deliberately is not:

| Path | Tracked | Notes |
|------|---------|-------|
| `CLAUDE.md`, `keybindings.json`, `statusline.sh` | yes | |
| `memory/*.md` | yes | Working preferences; `CLAUDE.md` `@`-includes four of them |
| `settings.json` | yes | Portable settings only — permissions, plugins, model, tui |
| `~/.claude/settings.local.json` | **no** | Machine-local. Holds the `hooks` block |
| `plugins/installed_plugins.json` | **no** | Runtime state: commit SHAs, absolute paths, timestamps |

The hooks live in `settings.local.json` rather than the tracked
`settings.json` because all ten of them invoke `~/.config/iterm2/cc-status`,
a compiled binary that is not in this repo. User-level `settings.json` and
`settings.local.json` merge, so splitting them this way keeps the tracked
file portable without changing behavior on this machine.

## Linting and Commit Hooks

`githooks/pre-commit` (wired by `make githooks`) runs two things before every
commit, and `git commit --no-verify` bypasses both:

1. `gitleaks git --staged` — a secret scan. Reviewed, non-actionable findings
   go in `.gitleaksignore`.
2. `make lint` — each check skips cleanly if its tool is missing, so the target
   passes on a machine that lacks fish or markdownlint-cli2.

**`git clean -fdx` deletes `zsh/dot-zsh/api_tokens.zsh`**, which holds live API
credentials and is not recoverable from git. It also deletes
`zsh/dot-zsh/completions/`, which zsh regenerates.
