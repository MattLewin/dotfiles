# ML: 2014-11-20
# To tell 'xmllint' where to find AsciiDoc's catalog files, I (apparently) have to do the following...
test -d "/usr/local/etc/xml/catalog" && export XML_CATALOG_FILES=/usr/local/etc/xml/catalog

# ML: 2015-11-10
# Use a token to authenticate against GitHub when using Homebrew to avoid rate limiting
test -e "${DOT_ZSH}/api_tokens.zsh" && source "${DOT_ZSH}/api_tokens.zsh"

# ML: 2015-11-29
# Set 'ls' to display size in KB rather than 512-byte blocks
export BLOCKSIZE=1024

# ML: 2017-05-31
test -d "/usr/local/opt/erlang/lib/erlang/man" && export MANPATH=$MANPATH:/usr/local/opt/erlang/lib/erlang/man

test -d "${HOME}/Library/Android/sdk" && export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"

# ML: 2018-02-07
# Use for local heroku apps (at least)
export DATABASE_URL=postgres://$(whoami)

# ML: 2018-02-26
# local environment variables I want passed to remote shells
test -n "$TERM_PROGRAM" && export LC_TERM_PROGRAM=$TERM_PROGRAM
test -n "$ITERM_SESSION_ID" && export LC_ITERM_SESSION_ID=$ITERM_SESSION_ID

# ML: 2018-02-26
# Configure terminal program specific environment for both local and remote terminals
case "$LC_TERM_PROGRAM" in
    Apple_Terminal)
        ;;

    iTerm.app)
        export ZSH_TMUX_ITERM2=true
        export ITERM_SESSION_ID=$LC_ITERM_SESSION_ID
        ;;
esac

# ML: 2018-11-20
# Configuration for bitrise at TrueMotion
if [ -e "$HOME/.truemotion" ]; then
    export DEMO_APP_API_TOKEN=invalid_token

    if [ -e "$HOME/.netrc" ]; then
        export ARTIFACTORY_USERNAME=$(grep login ~/.netrc | cut -d ' ' -f2)
        export ARTIFACTORY_PASSWORD=$(grep password ~/.netrc | cut -d ' ' -f2)
    fi
fi

# ML: 2019-06-29
# Prevent homebrew-file from doing anything with App Store apps
export HOMEBREW_BREWFILE_APPSTORE=0

# ML: 2019-07-15
# Circled numbers for pretty displays
circled_digits=$(printf %s \${$'\xEA',\`,{a..s}} | iconv -f UTF-16BE)
# circled_digits='⓪①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳'

[ ${commands[pass]} ] && export PASSWORD_STORE_GENERATED_LENGTH=14
