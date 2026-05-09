
export LESS="--tabs=4 -RFX" # tab breaks of size 4, output ANSI codes, don't clear screen

# To tell 'xmllint' where to find AsciiDoc's catalog files, I (apparently) have to do the following...
test -d "${BREW_PREFIX}/etc/xml/catalog" && export XML_CATALOG_FILES="${BREW_PREFIX}/etc/xml/catalog"

# Use a token to authenticate against GitHub when using Homebrew to avoid rate limiting
test -e "${DOT_ZSH}/api_tokens.zsh" && source "${DOT_ZSH}/api_tokens.zsh"

export BLOCKSIZE=1024 # Set 'ls' to display size in KB rather than 512-byte blocks

test -d "${BREW_PREFIX}/opt/erlang/lib/erlang/man" && export MANPATH=$MANPATH:${BREW_PREFIX}/opt/erlang/lib/erlang/man

test -d "${HOME}/Library/Android/sdk" && export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"

# Propagate terminal identity to remote shells via SSH.
# LC_ prefix is used because most SSH configs pass LC_* through by default.
test -n "$TERM_PROGRAM" && export LC_TERM_PROGRAM=$TERM_PROGRAM
test -n "$ITERM_SESSION_ID" && export LC_ITERM_SESSION_ID=$ITERM_SESSION_ID

# Configure terminal program specific environment for both local and remote terminals
case "$LC_TERM_PROGRAM" in
    Apple_Terminal)
        ;;

    iTerm.app)
        export ZSH_TMUX_ITERM2=true
        export ITERM_SESSION_ID=$LC_ITERM_SESSION_ID
        ;;
esac

# Prevent homebrew-file from doing anything with App Store apps
export HOMEBREW_BREWFILE_APPSTORE=0
export HOMEBREW_BUNDLE_FILE="${HOME}/.config/homebrew/Brewfile"

# Circled numbers for pretty displays
circled_digits=$(printf %s \${$'\xEA',\`,{a..s}} | iconv -f UTF-16BE)
# circled_digits='⓪①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'

(( $+commands[pass] )) && export PASSWORD_STORE_GENERATED_LENGTH=14
(( $+commands[fzf] )) && export FZF_DEFAULT_OPTS='--bind=ctrl-f:page-down,ctrl-b:page-up'
