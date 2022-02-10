#
# This file is meant to be sourced, not executed.
#

# Plugins to always load
plugins=(
    colored-man-pages
    colorize
    copybuffer
    copydir
    copyfile
    dotenv
    emoji
    fasd
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
    adb
    asdf
    aws
    bower
    brew
    bundler
    docker
    docker-compose
    fzf
    gcloud
    gem
    gh
    gradle
    grc
    helm
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
    rg ripgrep
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
        if [ ${commands[swiftenv]} ]
        then
            plugins+=(swiftenv)
            declare -xr SWIFTENV_ROOT=${BREW_PREFIX}/var/swiftenv
        fi

        # ruby-build installs a non-Homebrew OpenSSL for each Ruby version installed and these
        # are never upgraded. Below, we link Rubies to Homebrew's OpenSSL 1.1 (which is upgraded)
        if command -v ruby-build >/dev/null 2>&1 && [ -e "${BREW_PREFIX}/opt/openssl@1.1" ]
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
    conda-zsh-completion
    zsh-autosuggestions # https://github.com/zsh-users/zsh-autosuggestions.git
    # NOTE: zsh-syntax-highlighting must be the last plugin in the list of *all* plugins
    zsh-syntax-highlighting # https://github.com/zsh-users/zsh-syntax-highlighting.git
)

for plugin in "${custom_plugins[@]}"
do
    [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/${plugin} ] && plugins+=(${plugin})
done

# If zsh-autosuggestions plugin exists, then set its search strategy to 'completion'
if (($plugins[(Ie)zsh-autosuggestions])); then
    ZSH_AUTOSUGGEST_STRATEGY=(completion)
    ZSH_AUTOSUGGEST_USE_ASYNC=true
fi

if (($plugins[(Ie)nvm])); then
    NVM_AUTOLOAD=1      # load the version of node specified in ./.nvmrc
fi
