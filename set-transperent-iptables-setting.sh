#!/bin/bash


#iptables hints from here
#https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules
##iptables -t nat -A PREROUTING -p tcp -s 192.168.178.0/24 --dport 80 -j DNAT --to 192.168.178.32:3128

##iptables -t nat -A PREROUTING -p tcp -s 192.168.178.0/24 --dport 443 -j DNAT --to 192.168.178.32:3130


#show settings 
#sudo iptables -t nat -L
#sudo iptables -t nat -L -n -v --line-numbers

#sudo iptables -t mangle --line-numbers -L && sudo iptables -t nat --line-numbers -L

#sudo iptables -t mangle -n -v --line-numbers -L && sudo iptables -t nat -n -v --line-numbers -L

#delete chain
#first found number of chain
#sudo iptables -t nat --line-numbers -L PREROUTING
#delete vs chain number
#sudo iptables -t nat -D PREROUTING 2

# from here
# https://askubuntu.com/questions/348439/where-can-i-find-the-iptables-log-file-and-how-can-i-change-its-location
# sudo iptables -A INPUT -s 192.168.178.0/24 -j LOG --log-prefix='[netfilter] ' 
# sudo iptables -D INPUT -s 192.168.178.0/24 -j LOG --log-prefix='[netfilter] ' 

# sudo iptables -A INPUT -s 127.0.0.0/8 -j LOG --log-prefix='[netfilter] ' 
# sudo iptables -D INPUT -s 127.0.0.0/8 -j LOG --log-prefix='[netfilter] ' 

# iptables logging from here
# http://www.thegeekstuff.com/2012/08/iptables-log-packets/
# sudo iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 7
# sudo iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 7


#from here
#http://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxRedirect

# your proxy IP
SQUIDIP=$(cat currentContainerIpAddr.txt)

# your proxy listening port
#SQUIDPORT=3128

HTTP_PROXY_PORT=3129
HTTP_PORT=80
HTTPS_PROXY_PORT=
HTTPS_PPORT=443


#iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 80 -j ACCEPT
#iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $SQUIDPORT
#iptables -t nat -A POSTROUTING -j MASQUERADE
#iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT -j DROP


#mark all packet
#iptables -t mangle -I PREROUTING -p tcp -i eno1 ! -s 192.168.178.32 -j MARK --set-mark 1 --dport 80


iptables -t nat -A OUTPUT -p tcp --dport ${HTTP_PORT} -j DNAT --to ${IPADDR}:${HTTP_PROXY_PORT}
