# your proxy IP
SQUIDIP=192.168.178.32
 
# your proxy listening port
SQUIDPORT_HTTP=3128
SQUIDPORT_HTTPS=3130
 
# from here
#https://superuser.com/questions/769814/how-to-block-all-ports-except-80-443-with-iptables
#iptables -A INPUT -p tcp -m tcp -m multiport ! --dports 80,443 -j DROP
 
iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $SQUIDPORT_HTTP
iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 443 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port $SQUIDPORT_HTTPS
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT_HTTP -j DROP
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT_HTTPS -j DROP
