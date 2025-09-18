append_paths=()

if [ "${BREW_PREFIX}" != "" ]; then
    append_paths+=(
        "${BREW_PREFIX}/bin"
        "${BREW_PREFIX}/sbin"
    )
fi

append_paths+=(
    "/Applications/Docker.app/Contents/Resources/bin"
    "${HOME}/.cargo/bin"
    "${HOME}/.fastlane/bin"
    "${HOME}/.go/bin"
    "${HOME}/Content Creation/bin"
    "${HOME}/Library/Android/sdk/platform-tools"
    "${HOME}/.local/bin" # pipx path
    /sbin
    /usr/local/bin
    /usr/local/sbin
)

for new_path in "${append_paths[@]}"
do
    test -d "${new_path}" && PATH=${PATH}:${new_path}
done

prepend_paths=(
    "${HOME}/bin"
    "${HOME}/swift/usr/bin"
    "${BREW_PREFIX}/opt/ruby/bin"
    "${BREW_PREFIX}/opt/coreutils/libexec/gnubin"
)

for new_path in "${prepend_paths[@]}"
do
    test -d "${new_path}" && PATH="${new_path}":${PATH}
done

# custom bullshit to ensure we have the correct gems/bin path in our PATH
hb_ruby="${BREW_PREFIX}/opt/ruby/bin/ruby"
if [[ -x $hb_ruby ]]; then
    ruby_minor_version=$($hb_ruby -e 'puts "#{RUBY_VERSION[/\d+\.\d+/]}.0"')
    gem_bin_path="${BREW_PREFIX}/lib/ruby/gems/${ruby_minor_version}/bin"
    if [[ -d $gem_bin_path ]]; then
        export PATH="$gem_bin_path:$PATH"
    fi
fi

export PATH

function remove_duplicate_paths() {
    if [ -n "$PATH" ]; then
        old_PATH=$PATH:; unset PATH;
        while [ -n "$old_PATH" ]; do
            x=${old_PATH%%:*}       # the first remaining entry
            case $PATH: in
                *:"$x":*) ;;          # already there
                *) PATH=$PATH:$x;;    # not there yet
            esac
            old_PATH=${old_PATH#*:}
        done
        PATH=${PATH#:}
        unset old_PATH x
    fi
}
