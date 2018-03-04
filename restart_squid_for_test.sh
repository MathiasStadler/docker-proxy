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

./clean-iptables.sh  && \

service docker restart && \

~/Projects/ofGitHub/docker-proxy/run.sh ssl
