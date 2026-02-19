STOW_PACKAGES=bash git misc tmux zsh
INSTALL_SCRIPTS_DIR=install_scripts
ALL=homebrew antidote dotfiles launch-agents
BOOTSTRAP=bootstrap-local # excluded from ALL to avoid creating files outside repo on default `make`

STOW := $(or $(shell command -v stow), stow)
UNAME := $(shell uname)
SHELL := /bin/sh

.PHONY: $(ALL) $(BOOTSTRAP) stow homebrew

all: $(ALL)

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
	@echo --- Installing Homebrew if missing ---
	@${INSTALL_SCRIPTS_DIR}/install-homebrew.sh

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
