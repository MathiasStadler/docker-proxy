#!/bin/bash
# Check if we're root and re-execute if we're not.
# from here
# https://unix.stackexchange.com/questions/28454/how-do-i-force-the-user-to-become-root
rootcheck() {
    if [ "$(id -u)" != "0" ]; then
        sudo "$0" "$@" # Modified as suggested below.
        exit $?
    fi
}

rootcheck "$@"

iptables -t nat -L -n -v --line-numbers
iptables -t mangle -L -n -v --line-numbers
