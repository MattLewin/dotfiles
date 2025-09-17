# Intended to be *sourced*, not executed.
# Exports: OS KERNEL MACH ARCH DIST REV PSEUDONAME DistroBasedOn OS_STR

# If not sourced, $0 is this file; sourced, $0 is the shell.
case "$0" in *systeminfo.sh) echo "Source this file, don't execute it." >&2; return 1 2>/dev/null || exit 1;; esac

# Normalize and gather basics
OS=$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]'); : "${OS:=unknown}"
KERNEL=$(uname -r 2>/dev/null || printf '')
MACH=$(uname -m 2>/dev/null || printf '')
ARCH=$( (uname -p 2>/dev/null) || printf '%s' "$MACH" )

case "$OS" in
  darwin)
    if command -v sw_vers >/dev/null 2>&1; then
      # Example: "macOS 14.6.1"
      OS_STR="$(sw_vers -productName) $(sw_vers -productVersion)"
    else
      OS_STR="$(uname -srvmo 2>/dev/null)"
    fi
    DIST="macos"
    REV="${OS_STR##* }"   # version tail; fine if sw_vers not present
    PSEUDONAME=""
    DistroBasedOn="bsd"
    ;;

  linux)
    if [ -r /etc/os-release ]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      DIST=${ID:-linux}
      REV=${VERSION_ID:-}
      PSEUDONAME=${VERSION_CODENAME:-}
      DistroBasedOn=${ID_LIKE:-}
      OS_STR=${PRETTY_NAME:-"Linux $KERNEL"}
    else
      DIST="linux"; REV=""; PSEUDONAME=""; DistroBasedOn=""
      OS_STR="Linux $KERNEL"
    fi
    ;;

  *)
    DIST="$OS"; REV=""; PSEUDONAME=""; DistroBasedOn=""
    OS_STR="$(uname -srvmo 2>/dev/null)"
    ;;
esac

export OS KERNEL MACH ARCH DIST REV PSEUDONAME DistroBasedOn OS_STR