# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed with **GNU Stow** (symlink manager). Stow maps files with a `dot-` prefix into the home directory as `.`-prefixed symlinks (e.g., `zsh/dot-zshrc` → `~/.zshrc`).

## Key Commands

```bash
make              # Full install: Homebrew, Antidote, stow, launch agents
make dotfiles     # Re-stow all dotfiles (safe to re-run)
make bootstrap-local  # Create local override files (not in default `make`)
brew bundle       # Install Homebrew packages (auto-selects OS Brewfile)
```

Stow packages: `bash`, `git`, `misc`, `tmux`, `zsh`

## Architecture

### Naming Convention
All files managed by stow are prefixed with `dot-` (stow's `.stowrc` maps these to `.`-prefixed files in `$HOME`). The top-level directory name becomes the stow package name.

### Directory Layout
- `zsh/dot-zsh/` — Modular zsh config loaded by `.zshrc`
  - `plugins_builder.zsh` — Dynamically builds Antidote plugin list based on installed commands
  - `config.d/darwin.zsh` / `config.d/linux.zsh` — OS-specific settings
  - `aliases.zsh`, `paths.zsh`, `variables.zsh`, `fzf.zsh` — Functional modules
  - `api_tokens.zsh` — API credentials (git-ignored via `.gitignore`)
- `misc/dot-config/homebrew/Brewfile` — Single Brewfile (formulas + casks)
- `misc/dot-config/nvim/init.lua` — Neovim config (lazy.nvim plugin manager)
- `install_scripts/` — Bootstrap scripts called by Makefile targets
- `unstowed/` — Configs intentionally not symlinked by stow

### Local Overrides (Not Tracked)
Machine-specific settings live outside the repo to keep it portable:

| File | Purpose |
|------|---------|
| `~/.config/dotfiles/local.zsh` | Zsh overrides, sourced last in `.zshrc` |
| `~/.gitconfig.local` | Git user identity (name/email) |

Templates exist at `misc/dot-config/dotfiles/local.zsh.example` and `git/dot-gitconfig.local.example`.

### Platform Detection
- Makefile branches on `$(UNAME)` (Darwin vs Linux)
- Zsh branches via `zsh/dot-zsh/config.d/` directory — drop a `darwin.zsh` or `linux.zsh` file there
- macOS-only: launch agents in `launch_agents/` for SSH key management

### Zsh Plugin Management
Antidote is the plugin manager (`~/.antidote/`). The plugin list is built dynamically by `plugins_builder.zsh` — it checks for installed commands and only loads relevant plugins (e.g., aws plugin only if `aws` is in PATH). Syntax highlighting always loads last.

## Adding New Configs

1. Place files in the appropriate stow package directory with a `dot-` prefix
2. Run `make dotfiles` to re-stow
3. For new tools that should be cross-platform, add to `Brewfile.common`; macOS-only goes in `Brewfile.mac`
4. Machine-specific settings belong in `~/.config/dotfiles/local.zsh`, not in the repo
