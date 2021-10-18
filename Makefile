INSTALL_SCRIPTS_DIR=install_scripts
STOW_PACKAGES=bash conda git lldb misc tmux vim zsh

all: oh-my-zsh homebrew-file stow dotfiles launch-agents tex

dotfiles:
	stow --verbose=1 --dotfiles --target "${HOME}/" --ignore='^(?!dot).*$\' $(STOW_PACKAGES)

homebrew-file:
	$(INSTALL_SCRIPTS_DIR)/install-homebrew-file.sh

launch-agents:
	${INSTALL_SCRIPTS_DIR}/install-launch-agents.sh

oh-my-zsh:
	$(INSTALL_SCRIPTS_DIR)/install-oh-my-zsh.sh

stow:
	$(INSTALL_SCRIPTS_DIR)/install-stow.sh

tex:
	$(INSTALL_SCRIPTS_DIR)/install-tex-custom.sh
