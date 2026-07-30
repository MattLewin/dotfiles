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

# Note that this currently does nothing until/unless I create a guest network that is
# untrusted. For now, the only gateways that are trusted are the two VLANs on my Netgate 6100.
TRUSTED_GATEWAYS=(
  "172.21.21.1|90:ec:77:95:20:3a"   # Netgate 6100 VLAN 10 — trusted clients
  "172.22.22.1|90:ec:77:95:20:3a"   # Netgate 6100 VLAN 20 — trusted clients
)

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
