#!/bin/bash


#from here
#http://www.tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.cookbook.squid.html

IPADDR=$(cat currentContainerIpAddr.txt)
ROUTING_TABLE="TRANSPROXY"
MARK="0x4"

echo "IPADDR => ${IPADDR}"
echo "ROUTING_TABLE => ${ROUTING_TABLE}"
echo "MARK => ${MARK}"


#icmp REDIRECTs has to be disabled 
#echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
#echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
#echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects

#set mark of all packet with DPORT 80
#iptables -t mangle -A OUTPUT -dport 80 -j MARK --set-mark ${MARK} ||  exit 1
iptables -t mangle -A OUTPUT -p tcp  ! -s ${IPADDR} \
    -j MARK --set-mark ${MARK} --dport 80 || exit 1


iptables -t nat  -L  -n -v  --line-numbers

exit 0

# Add relevant iptables entries.
echo 202 ${ROUTING_TABLE} >> /etc/iproute2/rt_tables
ip rule add from all fwmark ${MARK} lookup ${ROUTING_TABLE}
ip route add default via "${IPADDR}" dev docker0 table ${ROUTING_TABLE}
ip route flush cache

ip rule show
ip route list table ${ROUTING_TABLE}

exit 0

#delete
sudo ip rule del fwmark 0x1 lookup TRANSPROXY


# Flush ALL THE THINGS.
ip route flush table main
ip route flush table 11
ip route flush table 21
ip rule flush

# Restore the basic rules and add our own.
ip rule add lookup default priority 32767
ip rule add lookup main priority 32766
ip rule add fwmark 11 priority 1000 table 11
# This next rule basically sends all other traffic down eth1.
ip rule add priority 2000 table 21

# Restore the main table.  I flushed it because OpenVPN does weird things to it.
ip route add 127.0.0.0/8 via 127.0.0.1 dev lo
ip route add 192.168.1.0/24 dev eth1 src 192.168.1.73
ip route add default via 192.168.1.254

# Set up table 21.  This sends all traffic to eth1.
ip route add 192.168.1.0/24 dev eth1 table 21
ip route add default via 192.168.1.254 dev eth1 table 21

# Set up table 11.  I honestly don't know why 'default' won't work, or
# why the second line here is needed.  But it works this way.
ip route add 10.32.0.49/32 dev tun0 table 11
ip route add 10.32.0.1 via 10.32.0.50 dev tun0 table 11
ip route add 0.0.0.0/1 via 10.32.0.50 dev tun0 table 11

ip route flush cache