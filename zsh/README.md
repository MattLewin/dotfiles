# zsh configuration

This is the `zsh` stow package. Stow maps every `dot-*` name into `$HOME`:

| Repo path | Symlinked to |
|-----------|--------------|
| `zsh/dot-zprofile` | `~/.zprofile` |
| `zsh/dot-zshrc` | `~/.zshrc` |
| `zsh/dot-zlogin` | `~/.zlogin` |
| `zsh/dot-zsh/` | `~/.zsh/` (whole tree) |

Plugin management is [Antidote](https://antidote.sh) — a *plugin loader*, not a
framework. There is no `~/.oh-my-zsh`, no `$ZSH`, no `plugins=(…)` array, no
`ZSH_THEME`. Everything Oh My Zsh used to do implicitly is now either an explicit
block in `~/.zshrc` or a small module file under `~/.zsh/`.

---

## "I used to do X in Oh My Zsh…"

| Oh My Zsh | Here |
|-----------|------|
| Add a plugin: append to `plugins=(…)` in `.zshrc` | Edit `dot-zsh/plugins_builder.zsh` (see [Plugins](#plugins)) |
| Bundled OMZ plugin (`git`, `aws`, …) | Still available — `plugins_builder.zsh` emits `ohmyzsh/ohmyzsh path:plugins/NAME` lines |
| Third-party plugin from GitHub | Add `owner/repo` to the `ALWAYS_ON` array in `plugins_builder.zsh` |
| Custom plugin in `$ZSH_CUSTOM/plugins/foo/foo.plugin.zsh` | Drop `foo.plugin.zsh` into `dot-zsh/plugins/` — auto-sourced by glob |
| Disable a custom plugin | Rename its extension (`foo.plugin.zsh` → `foo.plugin.zsh.off`) |
| `ZSH_THEME=…` | [Starship](https://starship.rs) (`starship init` at the end of `.zshrc`); falls back to an OMZ `shrink-path` prompt if starship isn't installed |
| OMZ `lib/` (completion styles, history opts, key bindings) | Hand-rolled: `zstyle` block in `.zshrc`, options in `.zshrc` + module files |
| `compinit` runs automatically | Explicit in `.zshrc`, with a once-a-day security audit (otherwise loads the cached dump with `-C`) |
| `omz update` | `antidote update` — or the `update-all` function (antidote + mise + brew) |
| Reload config | Same: `exec zsh` |

Key point: **to add a plugin you edit `plugins_builder.zsh`, not `.zshrc`.**
That script regenerates `~/.zsh_plugins.txt` on every shell start; Antidote
recompiles `~/.zsh_plugins.sh` from it only when the list actually changes.

---

## Load order

Login shells source `.zprofile` → `.zshrc` → `.zlogin`.

### `dot-zprofile`
Runs once, before `.zshrc`. Only job: `eval "$(brew shellenv)"` so Homebrew's
`PATH`/`MANPATH`/`INFOPATH` are set before anything else. Has hard-coded fallbacks
for `/opt/homebrew` and `/usr/local` if `brew` isn't on `PATH` yet.

### `dot-zshrc`
The orchestrator. In order:

1. `XDG_CONFIG_HOME`, `DOT_ZSH=~/.zsh`.
2. Source `~/.zsh/systeminfo.sh` → exports `OS`, `KERNEL`, `MACH`, `ARCH`, `DIST`, `REV`, `OS_STR`, …
3. `EDITOR` (nvim → vim), `typeset -U path`, misc options (`KEYTIMEOUT=10`, `HIST_STAMPS`).
4. `zmodload` `zsh/system`, `zsh/stat`.
5. Resolve `BREW_PREFIX`; set `USE_STARSHIP` flag (or install the fallback `PROMPT`).
6. **Before Antidote**, source in order: `paths.zsh`, `plugins_builder.zsh`.
7. Source `config.d/${OS}.zsh` if present (`darwin.zsh` / `linux.zsh`).
8. iTerm2 shell integration (if `TERM_PROGRAM == iTerm.app`).
9. Extend `fpath`: Homebrew `site-functions`, `zsh-completions`, `~/.zsh/completions`, Docker completions.
10. Completion `zstyle` block (case-insensitive matching, `menu select`, `cd` tuned to prefer dirs, history as fallback completer).
11. `compinit` — full audit + rebuild `.zcompdump` at most once per 24h, else `compinit -C -i`.
12. **Antidote**: source `antidote.zsh`; if `~/.zsh_plugins.txt` is newer than `~/.zsh_plugins.sh` (or the `.sh` is missing), re-bundle; then source `~/.zsh_plugins.sh`.
13. **After Antidote**, source in order: `aliases.zsh`, `variables.zsh`.
14. Source `~/.config/dotfiles/local.zsh` (untracked machine overrides).
15. Tool hooks: `direnv`, `RIPGREP_CONFIG_PATH` (`mole`/`ngrok`/`op` completions are cached by local plugins — step 16).
16. **Local plugins**: source every `~/.zsh/plugins/*.zsh` (glob; `null_glob`, readable only).
17. `zoxide init` (must be after compinit + plugins).
18. `starship init` (if `USE_STARSHIP`).
19. `zsh-autosuggestions` ignore rule for `gcmsg*`.

### `dot-zlogin`
Runs after `.zshrc`. Only when `TERM_PROGRAM == tmux`: `cd ~` and clear the dir
stack (keeps new tmux panes from inheriting a stale `dirs` list).

---

## Module files (`dot-zsh/`)

| File | When | Purpose |
|------|------|---------|
| `systeminfo.sh` | top of `.zshrc` | OS / distro detection; exports `OS`, `DIST`, `OS_STR`, … |
| `paths.zsh` | before Antidote | Builds `PATH`. `append_paths` / `prepend_paths` arrays, each entry added only if the dir exists. Also derives the Homebrew Ruby gem `bin` dir. |
| `plugins_builder.zsh` | before Antidote | Generates `~/.zsh_plugins.txt` (see [Plugins](#plugins)). |
| `aliases.zsh` | after Antidote | Normal / global / suffix aliases, shell functions, conditional command shadowing (`vi`→nvim, `python`→python3, `top`→htop, `find`→fd). Sources `fzf.zsh` when `fzf` exists. |
| `variables.zsh` | after Antidote | Environment: `LESS`, `HOMEBREW_*`, `DOTNET_CLI_TELEMETRY_OPTOUT`, `FZF_DEFAULT_OPTS`, `LC_TERM_PROGRAM` propagation, `circled_digits`. Sources `api_tokens.zsh`. |
| `fzf.zsh` | via `aliases.zsh` | fzf-powered functions: `cmd` (browse commands/aliases/functions with `man` preview), `brewlist`, etc. Bails without a tty. |
| `config.d/darwin.zsh` | step 7 | macOS-only: load SSH keys from Keychain; wrap `tmux` to use iTerm2's `-CC` integration for `new`/`attach`. |
| `config.d/linux.zsh` | step 7 | *(create this file for Linux-only settings)* |
| `api_tokens.zsh` | via `variables.zsh` | **Git-ignored** (`.gitignore` = `api_tokens*`). Secrets like `HOMEBREW_GITHUB_API_TOKEN`. Never committed. |
| `completions/` | on `fpath` | Custom completion functions (e.g. `_gen-yt-subtitles`). |

---

## Plugins

### 1. External plugins — `plugins_builder.zsh`

`_build_plugins()` writes `~/.zsh_plugins.txt` (Antidote's bundle input). It only
overwrites the file when the content changes, so a normal shell start does **not**
trigger an Antidote re-bundle.

Four sources feed the list:

```zsh
ALWAYS_ON=(          # loaded every shell
  ajeetdsouza/zoxide
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
  'ohmyzsh/ohmyzsh path:plugins/git'
  'ohmyzsh/ohmyzsh path:plugins/copypath'
  'ohmyzsh/ohmyzsh path:plugins/shrink-path'
)

WANT=( [aws]=aws )              # add OMZ plugin `aws` iff `aws` is on PATH

MAP=( [terminal-notifier]=bgnotify )   # binary name ≠ plugin name

# terminal-gated: adds OMZ `iterm2` when TERM_PROGRAM == iTerm.app
```

`zsh-users/zsh-syntax-highlighting` is always appended **last** (it must be).

**To add a plugin:**
- Unconditional → add `owner/repo` (or `owner/repo path:subdir`) to `ALWAYS_ON`.
- Only when a command exists → add `[plugin-name]=binary` to `WANT`, or
  `[binary]=plugin-name` to `MAP` if they differ.
- Then `exec zsh`. The list regenerates, Antidote re-bundles, done.

**Force a full rebuild:**
```zsh
rm ~/.zsh_plugins.txt ~/.zsh_plugins.sh && exec zsh
```

### 2. Local plugins — `dot-zsh/plugins/*.zsh`

Every `*.zsh` file here is sourced at the end of `.zshrc` (after compinit and
Antidote). No registration needed — just add the file. **Disable one by changing
its extension.** Most start with a `(( $+commands[x] )) || return 0` guard so
they're inert when the tool isn't installed.

| File | What it does |
|------|--------------|
| `aliases.plugin.zsh` | `aliases` — fuzzy-pick an alias name with `rg` + `fzf-tmux` |
| `bat.plugin.zsh` | `cat`→`bat` (tty only); `catp` / `catn` / `catc` variants |
| `bg-git-fetch.plugin.zsh` | Quiet `git fetch` on the zsh `periodic()` hook when idle inside a repo; `BG_GIT_FETCH_PERIOD` (default 300s) |
| `brew.plugin.zsh` | `brew` wrapper: `brew uses` → `--installed --recursive`; bare `brew outdated` → completion-friendly name list |
| `completions.plugin.zsh` | Data-driven cache of generated zsh completions (`clean_subtitles`, `color2hex`, `mole`, `ngrok`, `ruff`, `ttl`) in `$XDG_CACHE_HOME/zsh/completions`; regenerate per binary. Add a tool = one spec line |
| `dirstack.plugin.zsh` | `AUTO_PUSHD` + friends; `dstk` fzf dir-stack picker |
| `eza.plugin.zsh` | `ls`→`eza` (tty only); `l` `ll` `la` `lt` `ltree` `ltr` `lS` `ldot` … |
| `ffxxx.plugin.zsh` | Wrap `ffmpeg`/`ffplay`/`ffprobe`: always `-hide_banner`; auto `libdav1d` for AV1 input |
| `fzf.plugin.zsh` | Source Homebrew fzf's `completion.zsh` + `key-bindings.zsh` (only if not already loaded) |
| `git.plugin.zsh` | Plain git aliases: `ga` `gc` `gc!` `gcmsg` `gco` `gd` `gds` `gst` `gsw` `gswc` `glg` … |
| `iterm_title.plugin.zsh` | Set tab (`%~`) and window (`%n@%m:%~`) titles on each prompt; no OMZ dependency |
| `mise.plugin.zsh` | `eval "$(mise activate zsh)"` + cache `_mise` completion (regenerate on version change) |
| `op.plugin.zsh` | Generates/caches `_op` (1Password CLI) completion in `$XDG_CACHE_HOME/zsh/completions` (regenerate when binary changes; avoids a TCC prompt every startup) |
| `uv.plugin.zsh` | Route `pip`/`pipx` → `uv`/`uvx` (interactive only); caches `_uv`/`_uvx` completion in `$XDG_CACHE_HOME/zsh/completions` (regenerate when binary changes) |

---

## Common changes

| Want to… | Edit |
|----------|------|
| Add / change an alias | `dot-zsh/aliases.zsh` (git aliases → `dot-zsh/plugins/git.plugin.zsh`) |
| Add an env var | `dot-zsh/variables.zsh` |
| Add a dir to `PATH` | `dot-zsh/paths.zsh` (`append_paths` or `prepend_paths`) |
| Add an external plugin | `dot-zsh/plugins_builder.zsh` |
| Add your own plugin | new `*.plugin.zsh` in `dot-zsh/plugins/` |
| macOS-only tweak | `dot-zsh/config.d/darwin.zsh` |
| Linux-only tweak | create `dot-zsh/config.d/linux.zsh` |
| Completion tuning | `zstyle` block in `dot-zshrc` |
| Machine-specific / secret settings | `~/.config/dotfiles/local.zsh` (untracked; template at `misc/dot-config/dotfiles/local.zsh.example`) |

After editing an **existing** tracked file: nothing to re-stow (it's a symlink) —
just `exec zsh`. After adding a **new** file: `make dotfiles`, then `exec zsh`.

---

## Generated / cache files (not in the repo)

| Path | Written by | Contents |
|------|-----------|----------|
| `~/.zsh_plugins.txt` | `plugins_builder.zsh` | Antidote bundle input |
| `~/.zsh_plugins.sh` | Antidote | Compiled plugin bundle (sourced at startup) |
| `~/.antidote/` | Antidote | Cloned plugin repos |
| `~/.zcompdump` | `compinit` | Completion dump (rebuilt ≤ once/day) |
| `~/.zfunc/`, `~/.cache/zsh/completions/` | local plugins | Cached generated completions |
| `~/.config/dotfiles/local.zsh` | you | Untracked overrides, sourced last |

---

## Troubleshooting

- **Plugin change didn't take** — `rm ~/.zsh_plugins.txt ~/.zsh_plugins.sh && exec zsh`.
- **Stale completions** — `rm -f ~/.zcompdump ~/.zfunc/_* ~/.cache/zsh/completions/_* && exec zsh`.
- **Profile startup** — uncomment the two `XTRACE` blocks at the top and bottom of
  `dot-zshrc`; it logs per-line timings to a `zsh_profile.*` tempfile.
- **Update everything** — `update-all` (antidote + mise + brew), defined in `aliases.zsh`.
