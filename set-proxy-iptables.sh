#!/bin/bash

# your proxy IP
SQUIDIP=$(cat .currentContainerIpAddr.txt)

# your proxy listening port
SQUIDPORT=3128

iptables -t nat -A PREROUTING -s "$SQUIDIP" -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport "$SQUIDPORT" -j DROP

iptables -t nat  -L  -n -v  --line-numbers

#TODO old only a sample
# iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination ${IPADDR}:3129
# iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination ${IPADDR}:3130