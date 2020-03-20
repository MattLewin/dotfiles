#!/usr/bin/env bash
set -o errexit
set -o nounset

AGENTS_DIR="$(pwd)/launch_agents"
LIBRARY_LAUNCHAGENTS="${HOME}/Library/LaunchAgents"

echo "Installing launch agents"

for fq_agent in "${AGENTS_DIR}"/*.plist
do
    agent="$(basename -s .plist ${fq_agent})"
    echo "Installing launch agent: ${fq_agent}"
    ln -sf "${fq_agent}" "${LIBRARY_LAUNCHAGENTS}/"
    launchctl load "${LIBRARY_LAUNCHAGENTS}/${agent}.plist"
    launchctl start "${agent}"
done
