#!/bin/bash

BASH_PATH_HELPER=./bash_helper/bash_log_helper.sh
test -f $BASH_PATH_HELPER && source $BASH_PATH_HELPER

rootcheck() {
    if [ "$(id -u)" != "0" ]; then
        sudo "$0" "$@" # Modified as suggested below.
        exit $?
    fi
}

rootcheck "$@"

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -t nat  -L  -n -v --line-numbers