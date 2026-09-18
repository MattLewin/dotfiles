#!/bin/zsh
set -u

# This script checks the MAC address of the default gateway and enables or disables 
# stealth mode in the macOS firewall based on whether the gateway is trusted.
#
# Use command below to check the MAC address of your default gateway:
# gw=$(route -n get default | awk '/gateway:/ {print $2}'); arp -n "$gw"
#
# NOTE: macOS arp strips leading zeros from each octet, so a MAC that pfSense displays
# as 08:00:27:0a:1b:2c prints as 8:0:27:a:1b:2c. Command above will show the MAC in the
# format that should be used in TRUSTED_GATEWAYS.

# INSTALLATION INSTRUCTIONS
# Note: This is a system-level script that requires root privileges to run. It is intended to 
#       be run as a LaunchDaemon, not as a user-level LaunchAgent. The LaunchDaemon will run 
#       this script at system startup and whenever the network configuration changes.
#
# 1. Copy this script to /usr/local/libexec/wifi-stealth.zsh
# 2. Copy <dotfiles>/launch_agents/us.lewin.wifi-stealth.plist to /Library/LaunchDaemons/us.lewin.wifi-stealth.plist
# 2a. Copy <dotfiles>/misc/scripts/wifi-stealth.conf.example to
#     /usr/local/etc/wifi-stealth.conf and list your trusted gateways in it.
#     Without it, no gateway is trusted and stealth mode stays on.
# 3. Run the following commands to set the correct ownership and permissions:
#
# sudo chown root:wheel /usr/local/libexec/wifi-stealth.zsh
# sudo chmod 755 /usr/local/libexec/wifi-stealth.zsh
# sudo chown root:wheel /Library/LaunchDaemons/us.lewin.wifi-stealth.plist
# sudo chmod 644 /Library/LaunchDaemons/us.lewin.wifi-stealth.plist
# sudo launchctl bootstrap system /Library/LaunchDaemons/us.lewin.wifi-stealth.plist
# sudo launchctl kickstart -k system/us.lewin.wifi-stealth
#

FW=/usr/libexec/ApplicationFirewall/socketfilterfw
LOG=/var/log/wifi-stealth.log

# Trusted gateways are site-specific, so they live outside this repo in
# CONF (see wifi-stealth.conf.example for the format). If CONF is absent or
# empty, no gateway is trusted and stealth mode stays on -- the safe default.
CONF=/usr/local/etc/wifi-stealth.conf

TRUSTED_GATEWAYS=()
if [[ -r "$CONF" ]]; then
  while IFS= read -r line; do
    line="${line%%#*}"                 # strip comments
    line="${line//[[:space:]]/}"       # strip whitespace
    [[ -n "$line" ]] && TRUSTED_GATEWAYS+=("$line")
  done < "$CONF"
fi

trusted=0
gw=$(route -n get default 2>/dev/null | awk '/gateway:/ {print $2}')

if [[ -n "$gw" ]]; then
  ping -c1 -t1 -q "$gw" >/dev/null 2>&1        # populate ARP cache
  gw_mac=$(arp -n "$gw" 2>/dev/null | awk '{print $4}')
  for entry in $TRUSTED_GATEWAYS; do
    [[ "${gw}|${gw_mac}" == "$entry" ]] && trusted=1
  done
fi

(( trusted )) && want=off || want=on

if $FW --getstealthmode | grep -qi 'enabled'; then cur=on; else cur=off; fi

if [[ "$cur" != "$want" ]]; then
  $FW --setstealthmode "$want" >/dev/null
  print -r -- "$(date '+%F %T') gw=$gw mac=${gw_mac:-none} trusted=$trusted stealth $cur -> $want" >> "$LOG"
fi
