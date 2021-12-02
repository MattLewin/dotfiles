STOW_PACKAGES=bash conda git lldb misc tmux vim zsh
INSTALL_SCRIPTS_DIR=install_scripts
ALL=oh-my-zsh homebrew-file dotfiles launch-agents tex

STOW := $(or $(shell command -v stow), stow)
UNAME := $(shell uname)

.PHONY: $(ALL)

all: $(ALL)

dotfiles: | $(STOW)
	@echo --- Creating dot files ---
	stow --verbose=1 --dotfiles --target "${HOME}/" --ignore='^(?!dot).*$\' $(STOW_PACKAGES)

homebrew-file:
	@echo --- Installing Homebrew and homebrew-file ---
	@$(INSTALL_SCRIPTS_DIR)/install-homebrew-file.sh

launch-agents:
	@echo --- Installing custom launch agents ---
	@${INSTALL_SCRIPTS_DIR}/install-launch-agents.sh

oh-my-zsh:
	@echo --- Installing Oh My Zsh ---
	@$(INSTALL_SCRIPTS_DIR)/install-oh-my-zsh.sh

tex:
	@echo --- Installing custom LaTex paths ---
	@$(INSTALL_SCRIPTS_DIR)/install-tex-custom.sh

stow:
	@echo --- Installing stow ---
ifeq ($(UNAME), Darwin)
	brew install stow
else ifeq ($(UNAME), Linux)
	sudo apt-get install stow
else
	$(error Can't install stow, because WTF O.S. are you on?)
endif

