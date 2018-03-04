#!/bin/bash

# TODO set rules for iptables6

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

# your proxy IP (docker container)
#SQUIDIP=$(cat .currentContainerIpAddr.txt)
SQUIDIP="192.168.178.250"
# connection to outside the computer's cabinet => Campus Network.
# TODO find dynamical
readonly external_interface="enp0s8"

# your proxy listening port
readonly let SQUIDPORT=3128

# PORT 3120 not working because squid detetct SECURITY ALERT: Host header forgery detected on
# because squid has no access do nat different namespace
# NOT WORKING SQUIDPORT_HTTPS=3130
readonly let SQUIDPORT_HTTPS=3130
#SQUIDPORT=3129
# port 80 because the container has a seperate iptable rule to forward the right port
#SQUIDPORT=80

# TODO set dynamisch interfaces eno1
#
iptables -t nat -A PREROUTING -i "$external_interface" -s "$SQUIDIP" -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -i "$external_interface" -p tcp --dport 80 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
iptables -t nat -A POSTROUTING -o "$external_interface" -j MASQUERADE
iptables -t mangle -A PREROUTING -i "$external_interface" -p tcp --dport "$SQUIDPORT" -j DROP

exit 0;
#https
iptables -t nat -A PREROUTING -i "$external_interface" -s "$SQUIDIP" -p tcp --dport 443 -j ACCEPT
iptables -t nat -A PREROUTING -i "$external_interface" -p tcp --dport 443 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT_HTTPS"
iptables -t nat -A POSTROUTING -o "$external_interface" -j MASQUERADE
iptables -t mangle -A PREROUTING -i "$external_interface" -p tcp --dport "$SQUIDPORT_HTTPS" -j DROP

#TODO check why https packet dropped

iptables -t nat  -L  -n -v  --line-numbers

#TODO old only as sample
# iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination ${IPADDR}:3129
# iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination ${IPADDR}:3130
