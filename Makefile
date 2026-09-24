UNAME := $(shell uname)
STOW_PACKAGES=bash git misc tmux zsh
ifeq ($(UNAME), Darwin)
STOW_PACKAGES += macOS
endif
INSTALL_SCRIPTS_DIR=install_scripts
ALL=homebrew antidote dotfiles launch-agents githooks
BOOTSTRAP=bootstrap-local # excluded from ALL to avoid creating files outside repo on default `make`

STOW := $(or $(shell command -v stow), stow)
SHELL := /bin/sh

.PHONY: $(ALL) $(BOOTSTRAP) stow homebrew lint healthcheck

all: $(ALL)

# sh/bash scripts. install-launch-agents.sh + dnd_enabled are zsh, systeminfo.sh is sourced zsh -- all linted by zsh -n below
SH_SCRIPTS=$(INSTALL_SCRIPTS_DIR)/install-homebrew.sh $(INSTALL_SCRIPTS_DIR)/bootstrap-local.sh \
	misc/scripts/dotfiles-healthcheck misc/dot-claude/statusline.sh \
	.claude/hooks/lint-edited.sh
BASH_SCRIPTS=bash/dot-bashrc bash/dot-bash_profile
ZSH_FILES=zsh/dot-zshenv zsh/dot-zshrc zsh/dot-zprofile zsh/dot-zlogin zsh/dot-zsh/systeminfo.sh \
	$(INSTALL_SCRIPTS_DIR)/install-launch-agents.sh misc/scripts/dnd_enabled

lint:
	@echo --- shellcheck ---
	@shellcheck -e SC1091 $(SH_SCRIPTS)
	@shellcheck -e SC1091 -s bash $(BASH_SCRIPTS)
	@echo --- shfmt ---
	@shfmt -d -i 2 -ci $(SH_SCRIPTS)
	@shfmt -d -ln bash -i 2 -ci $(BASH_SCRIPTS)
	@echo --- zsh -n ---
	@fail=0; \
	for f in $$(find . -name '*.zsh' ! -name 'api_tokens.zsh') $(ZSH_FILES); do \
		zsh -n "$$f" || fail=1; \
	done; \
	exit $$fail
	@echo --- jq \(json validity\) ---
	@for f in $$(git ls-files '*.json'); do jq -e . "$$f" >/dev/null || exit 1; done
ifeq ($(UNAME), Darwin)
	@echo --- plutil \(plist validity\) ---
	@for f in $$(git ls-files '*.plist'); do plutil -lint "$$f" >/dev/null || exit 1; done
endif
	@echo --- fish -n ---
	@if command -v fish >/dev/null 2>&1; then \
		fail=0; \
		for f in $$(git ls-files '*.fish'); do \
			fish -n "$$f" || fail=1; \
		done; \
		exit $$fail; \
	else \
		echo "(skipped: fish not installed)"; \
	fi
	@echo --- markdownlint ---
	@if command -v markdownlint-cli2 >/dev/null 2>&1; then \
		markdownlint-cli2 $$(git ls-files '*.md'); \
	else \
		echo "(skipped: markdownlint-cli2 not installed)"; \
	fi
	@echo --- stow dry-run ---
	@stow -n --dotfiles --target "${HOME}/" $(STOW_IGNORE) $(STOW_PACKAGES)

# stow's --ignore matches basenames at EVERY level of a package, not just its
# root. A broad "^(?!dot).*$" pattern therefore ignores every file nested
# inside a dot-* directory too, which silently made misc/dot-claude/* unstowable.
# Target the two actual non-dot entries instead; stow's built-in defaults
# already skip README.*, LICENSE.*, editor backups and VCS directories.
STOW_IGNORE=--ignore='^scripts$$' --ignore='\.DS_Store$$' --ignore='\.example$$'

dotfiles: | $(STOW)
	@echo --- Creating dot files ---
	stow --verbose=1 --restow --dotfiles --target "${HOME}/" $(STOW_IGNORE) $(STOW_PACKAGES)


launch-agents:
ifeq ($(UNAME), Darwin)
	@echo --- Installing custom launch agents ---
	@${INSTALL_SCRIPTS_DIR}/install-launch-agents.sh
else
	@echo --- Skipping launch agents (macOS only) ---
endif


antidote:
	@echo --- Installing Antidote ---
	@ANTIDOTE_HOME="$$( [ -n "$${ZDOTDIR:-}" ] && [ "$${ZDOTDIR}" != "/" ] && printf '%s' "$${ZDOTDIR}" || printf '%s' "$(HOME)" )"; \
	if [ -d "$${ANTIDOTE_HOME}/.antidote" ]; then \
		echo "Antidote already installed at $${ANTIDOTE_HOME}/.antidote"; \
	else \
		git clone --depth=1 https://github.com/mattmc3/antidote.git "$${ANTIDOTE_HOME}/.antidote"; \
	fi

homebrew:
ifeq ($(UNAME), Darwin)
	@echo --- Installing Homebrew if missing ---
	@${INSTALL_SCRIPTS_DIR}/install-homebrew.sh
else
	@echo --- Skipping Homebrew (macOS only) ---
endif

stow:
	@echo --- Installing stow ---
ifeq ($(UNAME), Darwin)
	@if ! command -v brew >/dev/null 2>&1; then \
		${INSTALL_SCRIPTS_DIR}/install-homebrew.sh; \
	fi
	brew install stow
else ifeq ($(UNAME), Linux)
	sudo apt-get install stow
else
	$(error Can't install stow, because WTF O.S. are you on?)
endif

bootstrap-local:
	@echo --- Creating local override files ---
	@${INSTALL_SCRIPTS_DIR}/bootstrap-local.sh

healthcheck:
	@misc/scripts/dotfiles-healthcheck

githooks:
	@echo --- Wiring git hooks ---
	@git config core.hooksPath githooks
