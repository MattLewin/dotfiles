
export DOTNET_CLI_TELEMETRY_OPTOUT=1 # Set to 1 to disable .NET CLI telemetry, which is enabled by default.

export LESS="--tabs=4 -RFX" # tab breaks of size 4, output ANSI codes, don't clear screen

# To tell 'xmllint' where to find AsciiDoc's catalog files, I (apparently) have to do the following...
test -d "${BREW_PREFIX}/etc/xml/catalog" && export XML_CATALOG_FILES="${BREW_PREFIX}/etc/xml/catalog"

# Use a token to authenticate against GitHub when using Homebrew to avoid rate
# limiting. Lives outside the repo so it cannot be committed by accident;
# template at misc/dot-config/dotfiles/api_tokens.zsh.example.
test -e "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/api_tokens.zsh" &&
  source "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/api_tokens.zsh"

export BLOCKSIZE=1024 # Set 'ls' to display size in KB rather than 512-byte blocks

test -d "${BREW_PREFIX}/opt/erlang/lib/erlang/man" && export MANPATH=$MANPATH:${BREW_PREFIX}/opt/erlang/lib/erlang/man

test -d "${HOME}/Library/Android/sdk" && export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"

# Prevent homebrew-file from doing anything with App Store apps
export HOMEBREW_BREWFILE_APPSTORE=0
# Prevent homebrew from confirming upgrade
export HOMEBREW_NO_ASK=1
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/homebrew/Brewfile"

(( $+commands[pass] )) && export PASSWORD_STORE_GENERATED_LENGTH=14
(( $+commands[fzf] )) && export FZF_DEFAULT_OPTS='--bind=ctrl-f:page-down,ctrl-b:page-up'
