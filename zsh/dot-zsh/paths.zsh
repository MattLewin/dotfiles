append_paths=(
    "${HOME}/bin"
    /usr/local/bin
    /usr/local/sbin
    /sbin
    "${HOME}/.go/bin"
    "${HOME}/.cargo/bin"
    "${HOME}/.fastlane/bin"
    "${HOME}/Library/Android/sdk/platform-tools"
)

for new_path in "${append_paths[@]}"
do
    test -d "${new_path}" && PATH=${PATH}:${new_path}
done

prepend_paths=(
    "${HOME}/swift/usr/bin"
    "/usr/local/opt/coreutils/libexec/gnubin"
)

for new_path in "${prepend_paths[@]}"
do
    test -d "${new_path}" && PATH="${new_path}":${PATH}
done

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
