#!/bin/bash

# your proxy IP (docker container)
SQUIDIP=$(cat .currentContainerIpAddr.txt)

# your proxy listening port
#SQUIDPORT=3128
#SQUIDPORT=3129
# port 80 because the container has a seperate iptable rule to forward the right port
SQUIDPORT=80


iptables -t nat -A PREROUTING -s "$SQUIDIP" -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
# iptables -t nat -A POSTROUTING -j MASQUERADE
# iptables -t mangle -A PREROUTING -p tcp --dport "$SQUIDPORT" -j DROP

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