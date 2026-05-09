# dotfiles
macOS and UNIX configuration files

## Usage
Instead of cloning the repo, use this one as a template by clicking [here](https://github.com/MattLewin/dotfiles/generate), and then customize to your needs.

## Installation
clone the repo and all submodules

`make`

This will install [Antidote](https://getantidote.github.io/), [Homebrew](https://brew.sh), and [GNU stow](https://www.gnu.org/software/stow/). It will then use `stow` to link all your dot files into your home directory.

**CAUTION**: You probably *never* want to type `make`. This entire set up is heavily customized for my usage. I've made it available so others can copy, modify, and *then* deploy it for themselves.

`make` installs Homebrew if missing, then Antidote, stow, and dotfiles.

## Homebrew bundle

`misc/dot-config/homebrew/Brewfile`

Run with:

`brew bundle`

## Local overrides (portable setup)
To keep this portable across machines/users, put user-specific settings in local files that are not tracked:

- `~/.config/dotfiles/local.zsh` (zsh overrides)
- `~/.config/dotfiles/local.fish` (fish overrides)
- `~/.gitconfig.local` (git identity, per-user settings)

Create the local files from templates:

`install_scripts/bootstrap-local.sh`

Templates live at:

- `misc/dot-config/dotfiles/local.zsh.example`
- `misc/dot-config/dotfiles/local.fish.example`
- `git/dot-gitconfig.local.example`

## Zsh plugins (Antidote)

[Antidote](https://getantidote.github.io/) replaces Oh My Zsh. It's a lightweight plugin manager that clones repos and compiles them into a single sourceable file.

### How it works

Every shell startup, `plugins_builder.zsh` runs and writes `~/.zsh_plugins.txt` — a list of plugins to load (only if the list has changed). Then `.zshrc` checks whether `~/.zsh_plugins.txt` is newer than `~/.zsh_plugins.sh`; if so, Antidote recompiles the bundle:

```
antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
```

`~/.zsh_plugins.sh` is then sourced. This means plugin updates only take effect after the bundle is recompiled — which happens automatically the next time you open a shell after the plugin list changes.

Completions (`compinit`) run before plugins are sourced. `zsh-users/zsh-completions` adds extra completions on top of that. The compiled completion cache lives at `~/.zcompdump`.

### Adding a plugin

Edit `zsh/dot-zsh/plugins_builder.zsh`. There are two cases:

**Always load it** — add to the `ALWAYS_ON` array:
```zsh
local -a ALWAYS_ON=(
  ...
  owner/repo                                    # non-OMZ plugin
  'ohmyzsh/ohmyzsh path:plugins/plugin-name'   # OMZ plugin
)
```

**Load only when a binary is present** — add to the `WANT` map:
```zsh
typeset -A WANT=(
  [plugin-name]=binary-to-check-for
)
```

After editing, open a new shell. The plugin list will be rebuilt and Antidote will recompile the bundle automatically.

### Updating plugins

```bash
antidote update
```

Then open a new shell (or `source ~/.zsh_plugins.sh`) to pick up the changes.

### Local/custom plugins

Drop any `.zsh` file into `~/.zsh/plugins/`. It will be sourced automatically at startup — no Antidote involvement needed. Rename the extension to disable it.

### Syntax highlighting

`zsh-users/zsh-syntax-highlighting` is always forced to load last by `plugins_builder.zsh`. Don't move it.

## Health check
Quick check for required/optional tools:

`misc/scripts/dotfiles-healthcheck`

---
Copyright (c) Nobody, No rights reserved.
