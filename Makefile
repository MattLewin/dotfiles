STOW_PACKAGES=bash conda git lldb misc tmux vim zsh
INSTALL_SCRIPTS_DIR=install_scripts
ALL=oh-my-zsh homebrew-file dotfiles rust launch-agents

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

rust:
	@echo --- Installing Rust ---
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- --quiet -y --no-modify-path >/dev/null 2>&1

stow:
	@echo --- Installing stow ---
ifeq ($(UNAME), Darwin)
	brew install stow
else ifeq ($(UNAME), Linux)
	sudo apt-get install stow
else
	$(error Can't install stow, because WTF O.S. are you on?)
endif

tex:
	@echo --- Installing custom LaTex paths ---
	@$(INSTALL_SCRIPTS_DIR)/install-tex-custom.sh
