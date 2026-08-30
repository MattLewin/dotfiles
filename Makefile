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

.PHONY: $(ALL) $(BOOTSTRAP) stow homebrew lint

all: $(ALL)

# sh/bash scripts. install-launch-agents.sh + dnd_enabled are zsh, systeminfo.sh is sourced zsh -- all linted by zsh -n below
SH_SCRIPTS=$(INSTALL_SCRIPTS_DIR)/install-homebrew.sh $(INSTALL_SCRIPTS_DIR)/bootstrap-local.sh \
	misc/scripts/dotfiles-healthcheck misc/dot-claude/statusline.sh
BASH_SCRIPTS=bash/dot-bashrc bash/dot-bash_profile
ZSH_FILES=zsh/dot-zshrc zsh/dot-zprofile zsh/dot-zlogin zsh/dot-zsh/systeminfo.sh \
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

dotfiles: | $(STOW)
	@echo --- Creating dot files ---
	stow --verbose=1 --dotfiles --target "${HOME}/" --ignore='^(?!dot).*$\' $(STOW_PACKAGES)


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

githooks:
	@echo --- Wiring git hooks ---
	@git config core.hooksPath githooks
