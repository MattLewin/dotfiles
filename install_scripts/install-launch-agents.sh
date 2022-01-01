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
    # NOTE: this is using the obsolete 'load' and 'start' instead of
    #       'boostrap', because I couldn't make 'bootstrap' work
    launchctl load "${LIBRARY_LAUNCHAGENTS}/${agent}.plist"
    launchctl start "${agent}"
done
