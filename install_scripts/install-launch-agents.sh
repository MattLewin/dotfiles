#!/usr/bin/env zsh

#
# NOTE: this script assumes we are on macOS. Lame!
#

set -o errexit
set -o nounset

AGENTS_DIR="$(pwd)/launch_agents"
LIBRARY_LAUNCHAGENTS="${HOME}/Library/LaunchAgents"

for fq_agent in ${AGENTS_DIR}/*.plist(N.)
do
    agent="$(basename -s .plist ${fq_agent})"
    print "Installing launch agent: ${fq_agent}"
    ln -sf "${fq_agent}" "${LIBRARY_LAUNCHAGENTS}/"
    # Modern launchctl flow (per-user agents)
    if ! launchctl bootstrap "gui/${UID}" "${LIBRARY_LAUNCHAGENTS}/${agent}.plist" 2>/dev/null; then
        # If already loaded, unload then re-bootstrap
        launchctl bootout "gui/${UID}" "${LIBRARY_LAUNCHAGENTS}/${agent}.plist" 2>/dev/null || true
        launchctl bootstrap "gui/${UID}" "${LIBRARY_LAUNCHAGENTS}/${agent}.plist"
    fi
    launchctl enable "gui/${UID}/${agent}" 2>/dev/null || true
    launchctl kickstart -k "gui/${UID}/${agent}"
done
