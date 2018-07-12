#!/bin/bash

# check kernel settings

# Controls IP packet forwarding
# net.ipv4.ip_forward = 1
IP_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$IP_FORWARD" == "1" ]; then
	echo "net.ipv4.ip_forward = ${IP_FORWARD} => OK"
else
	echo "net.ipv4.ip_forward = ${IP_FORWARD} => NOT OK. Should be 1"
	echo "Set on the fly with >>> sysctl -w net.ipv4.ip_forward=1 <<<"
	sysctl -w net.ipv4.ip_forward=1
fi

# Controls source route verification
# net.ipv4.conf.default.rp_filter = 0
# explanation
# https://www.slashroot.in/linux-kernel-rpfilter-settings-reverse-path-filtering
RP_FILTER=$(cat /proc/sys/net/ipv4/conf/default/rp_filter)
if [ "$RP_FILTER" == "0" ]; then
	echo "net.ipv4.conf.default.rp_filter = ${RP_FILTER} => OK"
else
	echo "net.ipv4.conf.default.rp_filter = ${RP_FILTER} => NOT OK. Should be 0"
	echo "Set on the fly with >>> sudo sysctl -w net.ipv4.conf.all.rp_filter=0 <<<"
	sudo sysctl -w net.ipv4.conf.all.rp_filter=0
fi

# Do not accept source routing
# net.ipv4.conf.default.accept_source_route = 0
ACCEPT_SOURCE_ROUTE=$(cat cat /proc/sys/net/ipv4/conf/default/accept_source_route)
if [ "$ACCEPT_SOURCE_ROUTE" == "0" ]; then
	echo "net.ipv4.conf.default.rp_filter = ${RP_FILTER} => OK"
else
	echo "net.ipv4.conf.default.accept_source_route = ${ACCEPT_SOURCE_ROUTE} => NOT OK. Should be 0"
	echo "Set on the fly with >>> sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0 <<<"
	sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0
fi

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

# TODO set detect www wide interfaces
#
# from here
# https://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxDnat

# for http
iptables -t nat -A PREROUTING -i "$external_interface" -s "$SQUIDIP" -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -i "$external_interface" -p tcp --dport 80 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT"
iptables -t nat -A POSTROUTING -o "$external_interface" -j MASQUERADE
iptables -t mangle -A PREROUTING -i "$external_interface" -p tcp --dport "$SQUIDPORT" -j DROP

# disable
# for https
# iptables -t nat -A PREROUTING -i "$external_interface" -s "$SQUIDIP" -p tcp --dport 443 -j ACCEPT
# iptables -t nat -A PREROUTING -i "$external_interface" -p tcp --dport 443 -j DNAT --to-destination "$SQUIDIP:$SQUIDPORT_HTTPS"
# iptables -t nat -A POSTROUTING -o "$external_interface" -j MASQUERADE
# iptables -t mangle -A PREROUTING -i "$external_interface" -p tcp --dport "$SQUIDPORT_HTTPS" -j DROP

# TODO check why https packet dropped

iptables -t nat -L -n -v --line-numbers
