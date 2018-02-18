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

# name of routing table
ROUTINGTABLE="EXT_PROXY_CLIENT"

#router network
# TODO make dynamisch
external_interface="eno1"

# docker ip address
# TODO check docker container is started
# TODO check file exit and content valid
IPADDR=$(cat .currentContainerIpAddr.txt)

# add add  ROUTINGTABLE /etc/iproute2/rt_tables
# TODO make dynamic
# TODO check is available

# TODO hack make save and nice
# remove old entry of ROUTINGTABLE in /etc/iproute2/rt_tables
sudo sed -i "/.*${ROUTINGTABLE}.*/d" /etc/iproute2/rt_tables

[ -d /etc/iproute2 ] || sudo mkdir -p /etc/iproute2
if [ ! -e /etc/iproute2/rt_tables ]; then
    if [ -f /usr/local/etc/rt_tables ]; then
        sudo ln -s /usr/local/etc/rt_tables /etc/iproute2/rt_tables
    elif [ -f /usr/local/etc/iproute2/rt_tables ]; then
        sudo ln -s /usr/local/etc/iproute2/rt_tables /etc/iproute2/rt_tables
    fi
fi

log "info" "add  ROUTINGTABLE ${ROUTINGTABLE} /etc/iproute2/rt_tables"

([ -e /etc/iproute2/rt_tables ] && grep -q "${ROUTINGTABLE}" /etc/iproute2/rt_tables) ||
    sudo sh -c "echo '201	$ROUTINGTABLE' >> /etc/iproute2/rt_tables"

log "info" "All routings table in /etc/iproute2/rt_tables $(cat /etc/iproute2/rt_tables)"

log "info" "Delete all rules from ip rule of ROUTINGTABLE ${ROUTINGTABLE}"
sudo ip rule show | grep ${ROUTINGTABLE} | cut -d: -f1 | xargs -r -L1 sudo ip rule del prio

log "info" "Set ip rule"
ip rule show | grep -q "{$ROUTINGTABLE}" ||
    sudo ip rule add from all fwmark 0x4 lookup "${ROUTINGTABLE}"

ip rule show

# delete old ip if available
ip route show table "$ROUTINGTABLE" | grep -q default &&
    sudo ip route del default table "${ROUTINGTABLE}"

# set new ip route  for routing
sudo ip route add default via "${IPADDR}" dev docker0 table "${ROUTINGTABLE}"

log "info" "show route"
ip route show

log "info" "show route table ${ROUTINGTABLE}
    sudo ip route show table ${ROUTINGTABLE}"

# set iptables2 mangle rule
