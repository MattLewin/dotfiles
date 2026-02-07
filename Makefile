STOW_PACKAGES=bash git misc tmux zsh
INSTALL_SCRIPTS_DIR=install_scripts
ALL=antidote dotfiles launch-agents
BOOTSTRAP=bootstrap-local # excluded from ALL to avoid creating files outside repo on default `make`

STOW := $(or $(shell command -v stow), stow)
UNAME := $(shell uname)

.PHONY: $(ALL) $(BOOTSTRAP) stow

all: $(ALL)

dotfiles: | $(STOW)
	@echo --- Creating dot files ---
	stow --verbose=1 --dotfiles --target "${HOME}/" --ignore='^(?!dot).*$' $(STOW_PACKAGES)


launch-agents:
	@echo --- Installing custom launch agents ---
	@${INSTALL_SCRIPTS_DIR}/install-launch-agents.sh


antidote:
	@echo --- Installing Antidote ---
	@if [ -d "${ZDOTDIR:-$(HOME)}/.antidote" ]; then \
		echo "Antidote already installed at ${ZDOTDIR:-$(HOME)}/.antidote"; \
	else \
		git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$(HOME)}/.antidote"; \
	fi

stow:
	@echo --- Installing stow ---
ifeq ($(UNAME), Darwin)
	brew install stow
else ifeq ($(UNAME), Linux)
	sudo apt-get install stow
else
	$(error Can't install stow, because WTF O.S. are you on?)
endif

bootstrap-local:
	@echo --- Creating local override files ---
	@${INSTALL_SCRIPTS_DIR}/bootstrap-local.sh
