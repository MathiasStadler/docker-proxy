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

readonly let HTTP=80

readonly let HTTPS=443


# name of routing table
readonly ROUTINGTABLE="VAGRANT_PROXY_CLIENT"

#router network
# TODO make dynamisch
readonly external_interface="eno1"

# docker ip address
# TODO check docker container is started
# TODO check file exit and content valid
IPADDR="192.168.178.250"


# TODO check forwarding active
cat /proc/sys/net/ipv4/ip_forward

#IP OF TRAGET wo wird wirklich via hingerutetd

# your proxy IP (docker container)
SQUIDIP="192.168.178.250"

# TODO detect automatic save and nice
GATEWAY_INTERFACE="eno1"

# add add  ROUTINGTABLE /etc/iproute2/rt_tables
# TODO make dynamic
# TODO check is available

# TODO hack make save and nice
# TODO add while loop
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
    sudo ip rule add from all fwmark 0x6 lookup "${ROUTINGTABLE}"

ip rule show

# delete old ip if available
ip route show table "$ROUTINGTABLE" | grep -q default &&
    sudo ip route del default table "${ROUTINGTABLE}"

# set new ip route  for routingHost ip of DOCKER network
sudo ip route add default via "${SQUIDIP}" dev "${GATEWAY_INTERFACE}" table "${ROUTINGTABLE}"

log "info" "show route"

log "info" "show route table ${ROUTINGTABLE}
    sudo ip route show table ${ROUTINGTABLE}"

# set iptables2 mangle rule
# COMMON_RULES=" -t mangle -I PREROUTING -p tcp ! -s ${IPADDR}"

COMMON_RULES=" -t mangle -I PREROUTING -p tcp"

readonly MARK_RULES=" -j MARK --set-mark 6"

# set for port HTTP
sudo iptables ${COMMON_RULES} -i ${external_interface} -o ${SQUIDIP} --dport $HTTP  ${MARK_RULES}

# accept connection
iptables -t nat -A PREROUTING -i ${external_interface}  -p tcp --dport $HTTP -j ACCEPT

# set for port HTTPS
# sudo iptables ${COMMON_RULES} -i ${external_interface} --dport $HTTPS  ${MARK_RULES}

# accept connection
# iptables -t nat -A PREROUTING -i ${external_interface} -s "$SQUIDIP" -p tcp --dport $HTTPS -j ACCEPT

iptables -t nat -A POSTROUTING -o "$external_interface" -j MASQUERADE