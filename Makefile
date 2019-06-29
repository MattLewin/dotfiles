
INSTALL_SCRIPTS_DIR=install_scripts
STOW=/usr/local/bin/stow
STOW_PACKAGES=git vim zsh

homebrew-file:
	$(INSTALL_SCRIPTS_DIR)/install-homebrew-file.sh

oh-my-zsh:
	$(INSTALL_SCRIPTS_DIR)/install-oh-my-zsh.sh

stow:
	$(INSTALL_SCRIPTS_DIR)/install-stow.sh

dotfiles:
	$(STOW) --verbose=1 --dotfiles --target "${HOME}/" $(STOW_PACKAGES)
