# Use keychain to manage ssh-agent
if type -q keychain
    echo "keychain: loading SSH keys..."
    keychain --quiet --agents ssh ~/.ssh/id_ed25519-hoos
    keychain --quiet --eval ~/.ssh/id_ed25519-hoos | source
    keychain --quiet --agents ssh ~/.ssh/id_github
    keychain --quiet --eval ~/.ssh/id_github | source
    keychain --quiet --agents ssh ~/.ssh/id_rsa
    keychain --quiet --eval ~/.ssh/id_rsa | source
else
    echo "keychain: not installed; skipping SSH key setup"
end
