# from here
# http://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxRedirect


# your proxy IP
SQUIDIP=192.168.178.32

# your proxy listening port
SQUIDPORT=3129


iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $SQUIDPORT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT -j DROP