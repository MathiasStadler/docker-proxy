#!/bin/bash



# sudo iptables -t nat -I OUTPUT 1 -j LOG --log-prefix='[OUTPUT] '
# sudo iptables -t nat -I POSTROUTING  1 -j LOG --log-prefix='[POSTROUTING] '


#from here https://wiki.ubuntuusers.de/Squid/
#Unter Linux sollte aufs verwendet werden, da es hier Schreibzugriffe beschleunigt.

#squid -z
#squid -k parse


#relaod without restart
#https://www.cyberciti.biz/faq/howto-linux-unix-bsd-appleosx-reload-squid-conf-file/
#/usr/sbin/squid -k reconfigure 


#debug level
#debug_options ALL,1 33,2 28,9

#iptables log
#https://stackoverflow.com/questions/26963362/dockers-nat-table-output-chain-rule
#sudo iptables -t nat -I DOCKER -m limit --limit 2/min -j LOG --log-level 4 --log-prefix 'DOCKER CHAIN '

#localhost
#iptables -t nat -F  # clear table


#from here
#http://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxLocalhost

# normal transparent proxy
#iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j REDIRECT --to-port 3127

# handle connections on the same box (SQUIDIP is a loopback instance)
#gid=`id -g proxy`
#iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner $gid -j ACCEPT
#iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination SQUIDIP:3127

#--enable-net-filter

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

# sudo iptables -A INPUT -s 127.0.0.0/24 -j LOG --log-prefix='[netfilter] ' 
# sudo iptables -D INPUT -s 127.0.0.0/24 -j LOG --log-prefix='[netfilter] ' 

# iptables logging from here
# http://www.thegeekstuff.com/2012/08/iptables-log-packets/
# sudo iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 7
# sudo iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 7


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


#mark all packet
#iptables -t mangle -I PREROUTING -p tcp -i eno1 ! -s 192.168.178.32 -j MARK --set-mark 1 --dport 80
