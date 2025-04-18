#
# This file is meant to be sourced, not executed.
#

# Plugins to always load
plugins=(
    aliases
    colored-man-pages
    colorize
    copybuffer
    copyfile
    copypath
    dotenv
    emoji
    frontend-search
    genpass
    git
    git-auto-fetch
    gitignore
    history
    jsontools
    man
    shrink-path
    swiftpm
    systemadmin
    themes
    universalarchive
    vi-mode
    wd
    z
    zsh-navigation-tools
)

# ML: 2018-08-21: Include plugins if their corresponding binaries exist
binary_plugins=(
    asdf
    aws
    bower
    brew
    # bundler
    docker
    docker-compose
    fasd
    fzf
    gcloud
    gem
    gh
    gradle
    grc
    # helm ## the helm plugin overwrites the 'h' alias for 'history'
    heroku
    jfrog
    juju
    kubectl
    multipass
    mosh
    mvn
    nmap
    node
    pass
    perl
    pip
    pod
    pyenv
    python
    rbenv
    ruby
    terraform
    tldr
    tmux
    vagrant
    virtualenv
    yarn
)

for binary in "${binary_plugins[@]}"
do
    [ ${commands[$binary]} ] && plugins+=("${binary}")
done

# ML: 2018-08-21: Include plugins if their corresponding dot-config directories exist
config_plugins=(
    npm
    nvm
)

for config_dir in "${config_plugins[@]}"
do
    test -d "$HOME/.${config_dir}" && plugins+=(${config_dir})
done

# ML: 2018-08-30: Add plugins if an associated binary exists
#     The associative array key and values are <binary> <plugin name>
#     Note that the assoc. array syntax [key]=value only works on *some*
#     versions of ZSH. Why? I don't know.
typeset -A associated_plugins
associated_plugins+=(
    base64 encode64
    code vscode
    fortune chucknorris
    fzf zsh-interactive-cd
    go golang
    http httpie
    pip3 pip
    rustc rust
    task taskwarrior
    terminal-notifier bgnotify
    virtualenvwrapper.sh virtualenvwrapper
    xcode-select xcode
)

for binary plugin in ${(kv)associated_plugins}
do
    [ ${commands[$binary]} ] && plugins+=( ${plugin} )
done

typeset -A macOS_app_plugins
macOS_app_plugins+=(
    Bwana bwana
)

# ML: 2018-08-09: Add OS and distribution-specific plugins
case "$OS" in
    darwin)
        plugins+=(dash iterm2 macos)
        if ( [ ${commands[swiftenv]} ] && [ "${BREW_PREFIX}" != "" ] )
        then
            plugins+=(swiftenv)
            declare -xr SWIFTENV_ROOT=${BREW_PREFIX}/var/swiftenv
        fi

        # ruby-build installs a non-Homebrew OpenSSL for each Ruby version installed and these
        # are never upgraded. Below, we link Rubies to Homebrew's OpenSSL 1.1 (which is upgraded)
        if ( [ ${commands[ruby-build]} ] && [ -e "${BREW_PREFIX}/opt/openssl@1.1" ] )
        then
            export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${BREW_PREFIX}/opt/openssl@1.1"
        fi

        for app plugin in ${(kv)macOS_app_plugins}
        do
            [ -d "/Applications/${app}.app" ] && plugins+=( ${plugin} )
            [ -d "~/Applications/${app}.app" ] && plugins+=( ${plugin} )
        done

        HB_CNF_HANDLER="${BREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
        if [ -f "$HB_CNF_HANDLER" ]; then
            source "$HB_CNF_HANDLER";
            plugins+=(command-not-found)
        fi
        ;;

    linux)
        [ ${commands[systemctl]} ] && plugins+=(systemd)

        case "$DIST" in
            "centos linux")
                plugins+=(yum)
                ;;
            debian)
                plugins+=(debian)
                ;;
            suse)
                plugins+=(suse)
                ;;
            ubuntu)
                plugins+=(ubuntu)
                ;;
        esac
        ;;
esac

# Add 'thefuck' plugin only if we are using better than python3.4
[ ${commands[thefuck]} ] && [ ${commands[python3]} ] && test `python3 -c 'import sys; print("%i" % (sys.hexversion>0x03040000))'` -eq 1 && plugins+=(thefuck)

# Include plugins if their corresponding homebrew keg or cask is installed
homebrew_plugins=(
    git-flow
    git-flow-avh
)

for homebrew_plugin in "${homebrew_plugins[@]}"
do
    if [ -d "${BREW_PREFIX}/opt/${homebrew_plugin}" ] || [ -d "${BREW_PREFIX}/Caskroom/${homebrew_plugin}" ]
    then
        plugins+=(${homebrew_plugin})
    fi
done

#
# Grab the custom plugins using:
# git clone <repo URL> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/<plugin name>
#
custom_plugins=(
    clean_subtitles # One I wrote myself to support a subtitle clean up script I use for my content
)

for plugin in "${custom_plugins[@]}"
do
    [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/${plugin} ] && plugins+=(${plugin})
done

if (($plugins[(Ie)nvm])); then
    NVM_AUTOLOAD=1      # load the version of node specified in ./.nvmrc
fi
