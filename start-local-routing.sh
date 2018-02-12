iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3128
iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 80 -j DNAT --to-destination 192.168.4.96:3128

iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 3127
iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 443 -j DNAT --to-destination 192.168.4.96:3127
iptables -I INPUT -p tcp -m tcp --dport 3127 -j ACCEPT 
