#/bin/bash

#from here
#https://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxDnat

# your proxy IP
SQUIDIP=$(cat currentContainerIpAddr.txt)

# your proxy listening port
SQUIDPORT=3129
SQUIDPORT_HTTPS=3130

iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-destination $SQUIDIP:$SQUIDPORT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT -j DROP



iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 443 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-destination $SQUIDIP:$SQUIDPORT_HTTPS
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -A POSTROUTING -o docker0 -d 172.17.0.0/16 -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT_HTTPS -j DROP