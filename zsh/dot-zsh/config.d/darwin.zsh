# macOS-specific zsh config

if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add --apple-load-keychain
fi

# Use iTerm2 tmux integration for session creation/attachment
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    tmux() {
        case "${1:-}" in
            new|new-session|attach|attach-session|a|"")
                command tmux -CC "$@"
                ;;
            *)
                command tmux "$@"
                ;;
        esac
    }
fi
