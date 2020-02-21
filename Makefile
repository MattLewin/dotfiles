HOST=$(shell hostname -s)
INSTALL_SCRIPTS_DIR=install_scripts
STOW=/usr/local/bin/stow
STOW_PACKAGES=bash conda git lldb misc tmux vim zsh

all: oh-my-zsh homebrew-file stow dotfiles tex

homebrew-file:
	$(INSTALL_SCRIPTS_DIR)/install-homebrew-file.sh

oh-my-zsh:
	$(INSTALL_SCRIPTS_DIR)/install-oh-my-zsh.sh

stow:
	$(INSTALL_SCRIPTS_DIR)/install-stow.sh

dotfiles:
	$(STOW) --verbose=1 --dotfiles --target "${HOME}/" --ignore='^(?!dot).*$\' $(STOW_PACKAGES)
	@# work around a weird bug in brewfile
	@(cd misc/dot-config/brewfile && ln -sf ${HOST}.Brewfile .Brewfile)

tex: 
	$(INSTALL_SCRIPTS_DIR)/install-tex-custom.sh
