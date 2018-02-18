#!/bin/bash

# your proxy IP (docker container)
SQUIDIP=$(cat .currentContainerIpAddr.txt)

external_interface="eno1"

readonly let HTTP=80

readonly let HTTPS=443

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
# # iptables -t nat -A PREROUTING -i eno1 -s "$SQUIDIP" -p tcp --dport 80 -j ACCEPT
# # iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 80 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
# # iptables -t nat -A POSTROUTING -j MASQUERADE
# # iptables -t mangle -A PREROUTING -i eno1 -p tcp --dport "$SQUIDPORT" -j DROP

#https
# # iptables -t nat -A PREROUTING -i eno1 -s "$SQUIDIP" -p tcp --dport 443 -j ACCEPT
# # iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 443 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT_HTTPS"
# # iptables -t nat -A POSTROUTING -j MASQUERADE
# # iptables -t mangle -A PREROUTING -i eno1 -p tcp --dport "$SQUIDPORT_HTTPS" -j DROP

# TODO remove iptables rule

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

function error_rule_number() {

    echo "ERROR :: iptables rule number wring ${1}"

    exit 1
}

set +x
# disable
# iptables -t nat -A PREROUTING -i eno1 -s "$SQUIDIP" -p tcp --dport 80 -j ACCEPT
while true; do
    rule_num=$(sudo iptables -t nat -v -n -L PREROUTING --line-numbers |
        grep -E "ACCEPT.*tcp.*$SQUIDIP.*tcp.*dpt.*:$HTTP.*" |
        awk '{print $1}' |
        head -n1)

    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t nat -v -n -L PREROUTING "${rule_num}"
    sudo iptables -t nat -D PREROUTING "${rule_num}"
done
#
# disable
# iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 80 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
while true; do
    # 'DNAT.*tcp.*eno1.*tcp.*dpt:80.*to.*172.17.0.2:3128'
    # TODO old echo "DNAT.*tcp.*$external_interface.*tcp.*dpt:$HTTP.*to.*$SQUIDIP:$SQUIDPORT"
    rule_num=$(sudo iptables -t nat -v -n -L PREROUTING --line-numbers |
        grep -E "DNAT.*tcp.*$external_interface.*tcp.*dpt:$HTTP.*to.*$SQUIDIP:$SQUIDPORT" |
        awk '{print $1}' |
        head -n1)

    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t nat -v -n -L PREROUTING "${rule_num}"
    sudo iptables -t nat -D PREROUTING "${rule_num}"
done
# disable
# iptables -t nat -A POSTROUTING -j MASQUERADE
while true; do
    # TODO old echo "MASQUERADE.*all.*--.*"
    rule_num=$(sudo iptables -t nat -v -n -L POSTROUTING --line-numbers |
        grep -E "MASQUERADE.*all.*--.*$external_interface.*" |
        awk '{print $1}' |
        head -n1)

    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t nat -v -n -L POSTROUTING "${rule_num}"
    sudo iptables -t nat -D POSTROUTING "${rule_num}"
done
# disable
# iptables -t mangle -A PREROUTING -i eno1 -p tcp --dport "$SQUIDPORT" -j DROP
while true; do
    # TODO old echo "DROP.*tcp.*$external_interface.*tcp.*dpt:$SQUIDPORT"
    rule_num=$(sudo iptables -t mangle -L PREROUTING -v -n --line-numbers |
        grep -E "DROP.*tcp.*$external_interface.*tcp.*dpt:$SQUIDPORT" |
        awk '{print $1}' |
        head -n1)
    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t mangle -n -L PREROUTING "${rule_num}" || error_rule_number ${rule_num}
    sudo iptables -t mangle -D PREROUTING "${rule_num}" || error_rule_number ${rule_num}
    # set string rule_num to null, string length null
    rule_num=""
    # loop done
done

# https part

# disable
# iptables -t nat -A PREROUTING -i eno1 -s "$SQUIDIP" -p tcp --dport 443 -j ACCEPT
while true; do
    rule_num=$(sudo iptables -t nat -v -n -L PREROUTING --line-numbers |
        grep -E "ACCEPT.*tcp.*$SQUIDIP.*tcp.*dpt.*:$HTTPS.*" |
        awk '{print $1}' |
        head -n1)

    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t nat -v -n -L PREROUTING "${rule_num}"
    sudo iptables -t nat -D PREROUTING "${rule_num}"
done
#
# disable
# iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 443 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
while true; do
    # 'DNAT.*tcp.*eno1.*tcp.*dpt:80.*to.*172.17.0.2:3128'
    # TODO old echo "DNAT.*tcp.*$external_interface.*tcp.*dpt:$HTTPS.*to.*$SQUIDIP:$SQUIDPORT_HTTPS"
    rule_num=$(sudo iptables -t nat -v -n -L PREROUTING -v --line-numbers |
        grep -E "DNAT.*tcp.*$external_interface.*tcp.*dpt:$HTTPS.*to.*$SQUIDIP:$SQUIDPORT_HTTPS" |
        awk '{print $1}' |
        head -n1)

    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t nat -v -n -L PREROUTING -v "${rule_num}"
    sudo iptables -t nat -D PREROUTING "${rule_num}"
done
# disable
# iptables -t nat -A POSTROUTING -j MASQUERADE
while true; do
    # TODO old echo "MASQUERADE.*all.*--.*"
    rule_num=$(sudo iptables -t nat -v -n -L POSTROUTING --line-numbers |
        grep -E "MASQUERADE.*all.*--.*$external_interface.*" |
        awk '{print $1}' |
        head -n1)

    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t nat -v -n -n -L POSTROUTING "${rule_num}"
    sudo iptables -t nat -D POSTROUTING "${rule_num}"
done
# disable
# iptables -t mangle -A PREROUTING -i eno1 -p tcp --dport "$SQUIDPORT" -j DROP
while true; do
    # TODO old echo "DROP.*tcp.*$external_interface.*tcp.*dpt:$SQUIDPORT"
    rule_num=$(sudo iptables -t mangle -L PREROUTING -v -n --line-numbers |
        grep -E "DROP.*tcp.*$external_interface.*tcp.*dpt:$SQUIDPORT_HTTPS" |
        awk '{print $1}' |
        head -n1)
    [ -z "$rule_num" ] && break
    echo -en "DELETE RULE => "
    sudo iptables -t mangle -v -n -L PREROUTING "${rule_num}" || error_rule_number ${rule_num}
    sudo iptables -t mangle -D PREROUTING "${rule_num}" || error_rule_number ${rule_num}
    # set string rule_num to null, string length null
    rule_num=""
    # loop done
done

set +x

# TODO old ./show-iptables.sh
