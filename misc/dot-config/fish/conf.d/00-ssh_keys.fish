# Load SSH keys into a keychain-managed ssh-agent.
#
# Keys are listed inline rather than pulled from a machine-local file: the
# cost of an extra setup step, and of silently loading nothing when it is
# missing, outweighs keeping a few key filenames out of this repo. Missing
# keys are skipped, so this is harmless on a machine that has none of them.

type -q keychain; or return

set -l keys ~/.ssh/id_ed25519-hoos ~/.ssh/id_github ~/.ssh/id_rsa

set -l present
for k in $keys
    test -r $k; and set -a present $k
end
set -q present[1]; or return

keychain --quiet --agents ssh $present
keychain --quiet --eval --agents ssh $present | source
