# macOS-specific zsh config

if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add --apple-load-keychain
fi
