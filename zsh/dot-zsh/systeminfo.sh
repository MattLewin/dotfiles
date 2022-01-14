#!/usr/bin/env zsh

####################################################################
# Get System Info
####################################################################
_getsysteminfo() {
    # typeset -l forces the envionment variable to be lowercase
    typeset -xl OS=$(uname -s) # operating system name (NOTE: the -x is required or it will not export later)
    KERNEL=$(uname -r) # operating system kernel version
    MACH=$(uname -m) # machine hardware name
    ARCH=$(uname -p 2>/dev/null || uname -m) # processor type or machine hardware name, if uname -p is unavailable

    if [ "${OS}" = "windowsnt" ]; then
        OS=windows
    elif [ "${OS}" = "darwin" ]; then
        OS_STR=$(uname -v) # operating system version string
    else
        OS=$(uname)
        if [ "${OS}" = "sunos" ]; then
            OS=solaris
            OS_STR="${OS} (${ARCH} $(uname -v))"
        elif [ "${OS}" = "aix" ]; then
            OS_STR="${OS} $(oslevel) ($(oslevel -r))"
        elif [ "${OS}" = "linux" ]; then
            if [ -f /etc/redhat-release ]; then
                DistroBasedOn='RedHat'
                DIST=$(cat /etc/redhat-release | sed 's/\ release.*//')
                PSEUDONAME=$(cat /etc/redhat-release | sed 's/.*(//' | sed 's/)//')
                REV=$(cat /etc/redhat-release | sed 's/.*release\ //' | sed 's/\ .*//')
            elif [ -f /etc/SuSE-release ]; then
                DistroBasedOn='SuSe'
                PSEUDONAME=$(cat /etc/SuSE-release | tr "\n" ' ' | sed 's/VERSION.*//')
                REV=$(cat /etc/SuSE-release | tr "\n" ' ' | sed 's/.*=\ //')
            elif [ -f /etc/mandrake-release ]; then
                DistroBasedOn='Mandrake'
                PSEUDONAME=$(cat /etc/mandrake-release | sed 's/.*(//' | sed 's/)//')
                REV=$(cat /etc/mandrake-release | sed 's/.*release\ //' | sed 's/\ .*//')
            elif [ -f /etc/debian_version ]; then
                DistroBasedOn='Debian'
                if [ -f /etc/lsb-release ]; then
                    DIST=$(cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F= '{ print $2 }')
                    PSEUDONAME=$(cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F= '{ print $2 }')
                    REV=$(cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F= '{ print $2 }')
                fi
            fi
            if [ -f /etc/UnitedLinux-release ]; then
                DIST="${DIST}[$(cat /etc/UnitedLinux-release | tr "\n" ' ' | sed 's/VERSION.*//')]"
            fi
        fi
    fi

    # `typeset -gxlr` exports the variables as read-only and lowercase in the global context
    typeset -gxlr ARCH DIST DistroBasedOn KERNEL MACH OS PSEUDONAME REV
    typeset -gxr OS_STR # We want to preserve the case of the OS string
}

_getsysteminfo
unset -f _getsysteminfo
