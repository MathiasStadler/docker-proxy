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


#iptables logging from here
#http://www.thegeekstuff.com/2012/08/iptables-log-packets/



#from here
#http://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxRedirect

# your proxy IP
SQUIDIP=192.168.178.32

# your proxy listening port
SQUIDPORT=3128


iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $SQUIDPORT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT -j DROP


iptables -t mangle -I PREROUTING -p tcp -i eno1 ! -s 192.168.178.32 -j MARK --set-mark 1 --dport 80