#!/bin/bash
#iptables -t nat -F  # clear table

# your proxy IP
SQUIDIP=192.168.178.32


SQUID_PORT=3128
echo $SQUID_PORT
INTERNET_DEVICE=eno1
echo $INTERNET_DEVICE
# normal transparent proxy
#iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j REDIRECT --to-port 3127

# handle connections on the same box (SQUIDIP is a loopback instance)
#PROXY_USER_UID=`id -g proxy`
PROXY_USER_UID=13
gid=1000
echo $gid

iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination $SQUIDIP:3128


iptables -t nat -A OUTPUT -p tcp --dport 443 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination $SQUIDIP:3130

#from here http://www.squid-cache.org/mail-archive/squid-users/200707/0712.html
#iptables -t nat -A OUTPUT -o $INTERNET_DEVICE -p tcp --dport 80 \
#        -m owner --uid-owner $PROXY_USER_UID -j ACCEPT 

#iptables -t nat -A OUTPUT -o $INTERNET_DEVICE -p tcp --dport 80 \
#-j REDIRECT --to-port $SQUID_PORT 
