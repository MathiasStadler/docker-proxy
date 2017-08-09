# your proxy IP
SQUIDIP=192.168.178.32
 
# your proxy listening port
SQUIDPORT=3128
 

IPTABLES=/sbin/iptables

LAN_INT="eno1"

$IPTABLES -t nat -I PREROUTING  -i $LAN_INT -p tcp -m tcp --dport 443 -j REDIRECT --to-ports $SQUIDPORT 



