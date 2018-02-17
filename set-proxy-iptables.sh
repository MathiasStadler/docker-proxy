#!/bin/bash

# your proxy IP (docker container)
SQUIDIP=$(cat .currentContainerIpAddr.txt)

# connection to outside the computer's cabinet => Campus Network.
# TODO find dynamical
readonly external_interface="eno1"

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
iptables -t nat -A POSTROUTING -i "$external_interface" -j MASQUERADE
iptables -t mangle -A PREROUTING -i "$external_interface" -p tcp --dport "$SQUIDPORT" -j DROP


#https
iptables -t nat -A PREROUTING -i "$external_interface" -s "$SQUIDIP" -p tcp --dport 443 -j ACCEPT
iptables -t nat -A PREROUTING -i "$external_interface" -p tcp --dport 443 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT_HTTPS"
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -i "$external_interface" -p tcp --dport "$SQUIDPORT_HTTPS" -j DROP

#TODO check why https packet dropped

iptables -t nat  -L  -n -v  --line-numbers

#TODO old only as sample
# iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination ${IPADDR}:3129
# iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination ${IPADDR}:3130


exit 0

# TODO remove iptables rule
set -x
while true; do
rule_num=$(sudo iptables -t nat -L PREROUTING -n --line-numbers |
            grep -E 'ACCEPT.*tcp dpt:80' |
            awk '{print $1}' |
            head -n1)

[ -z "$rule_num" ] && break
sudo iptables -t nat -D PREROUTING "${rule_num}"
done
#
while true; do
rule_num=$(sudo iptables -t nat -L PREROUTING -n --line-numbers |
            grep -E 'DNAT.*tcp dpt:80 to: $SQUIDIP:80' |
            awk '{print $1}' |
            head -n1)

[ -z "$rule_num" ] && break
sudo iptables -t nat -D PREROUTING "${rule_num}"
done
set +x