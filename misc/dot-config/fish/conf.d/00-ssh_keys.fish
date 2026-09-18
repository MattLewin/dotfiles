# Load SSH keys into a keychain-managed ssh-agent.
#
# The key list is machine-specific, so it lives outside this repo in
# ~/.config/dotfiles/ssh_keys.fish, which should contain one line:
#
#     set -g dotfiles_ssh_keys ~/.ssh/id_ed25519 ~/.ssh/id_github
#
# That file is separate from local.fish on purpose: conf.d snippets run
# *before* config.fish, and local.fish is sourced last so it can override
# things. Machine facts that conf.d needs cannot live there.

set -l keyfile (set -q XDG_CONFIG_HOME; and echo "$XDG_CONFIG_HOME"; or echo "$HOME/.config")/dotfiles/ssh_keys.fish
test -r "$keyfile"; and source "$keyfile"

set -q dotfiles_ssh_keys; or return
type -q keychain; or return

keychain --quiet --agents ssh $dotfiles_ssh_keys
keychain --quiet --eval --agents ssh $dotfiles_ssh_keys | source
