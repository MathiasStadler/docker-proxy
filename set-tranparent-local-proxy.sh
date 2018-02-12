#!/bin/bash
# https://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxLocalhost

# your proxy IP
SQUIDIP=$(cat currentContainerIpAddr.txt)

# your proxy listening port
SQUIDPORT=3129

# print gid of process
# ps o user,pid,%cpu,%mem,vsz,rss,tty,stat,start,time,comm,group,gid

# gid of proxy/squid
gid=$(id -g proxy)

# iptables -t nat -A PREROUTING -s "${SQUIDIP}" -p tcp --dport 80 -j ACCEPT
# iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination "${SQUIDIP}:${SQUIDPORT}"
# iptables -t nat -A POSTROUTING -j MASQUERADE
# iptables -t mangle -A PREROUTING -p tcp --dport "${SQUIDPORT}" -j DROP

echo "gid of ${gid}"
sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner "${gid}" -j ACCEPT
sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination "${SQUIDIP}:${SQUIDPORT}"
sudo iptables -t nat -A OUTPUT -p tcp --dport 443 -m owner --gid-owner "${gid}" -j ACCEPT
sudo iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination "${SQUIDIP}:${SQUIDPORT}"
