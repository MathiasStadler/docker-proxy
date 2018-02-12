# docker-proxy
My copy of silarsis/docker-proxy with my config 



# edit squid.conf
* vi squid.conf
* build docker images new
    * docker build  -t docker-proxy .

# DOCKER build behind proxy
* add --build-arg http_proxy=http://192.168.178.32:3128
* sample ```docker build --build-arg http_proxy=http://192.168.178.32:3128 -t mathiasstatdler/postgres .```
* from here  https://github.com/docker/docker-registry/issues/890
    - thx Anders Janmyr for the Idea <https://github.com/andersjanmyr>


# ERROR Connection rest by cliant 
- ERROR was rised by SQUID DOCKER WGET during the build process 
    - add --enable-http-violations  to squid.patch
    - add ``` via off
forwarded_for delete ```


#Howto Exclude Few Sites from Caching
* from here
*  https://aacable.wordpress.com/2012/01/23/squid-howto-exclude-some-sites-exntension-from-caching/

* ``` acl NO-CACHE-SITES dstdomain "/etc/squid/not-to-cache-sites.txt"
no_cache deny NO-CACHE-SITES
acl sharing_server dst 10.0.0.1
cache deny sharing_server

Now create the file which will contains our sites list which we don’t want to cache.

touch /etc/squid/not-to-cache-sites.txt

and add  your desired web sites name in /etc/squid/not-to-cache-sites.txt
For example

nano /etc/squid/not-to-cache-sites.txt


and add following or your entries

bankalhabib.com
aacable.wordpress.com
wordpress.com
nae.com.pk
jang.com.pk ```

- Special thanks go to Kevin Littlejohn 


# helps
- ```docker exec -it $(cat currentSquidContainer.id) /bin/bash```

- ```docker cp $(cat currentSquidContainer.id):/etc/squid/ssl_cert/ca.der . ```

- delete old cert new are create than by the next start
- ```docker exec -it  $(cat currentSquidContainer.id) rm /etc/squid/ssl_cert/ca.pem```


# debug openssl

- ```openssl s_client -connect 192.168.178.32:443 -state -debug```
- from here
- ```https://forum.ubuntuusers.de/topic/ssl-error-rx-record-too-long/```
- ``` http://www.mozilla.org/projects/secur.html#1040263 sagt zu deiner Firefoxmeldung:
    SL_ERROR_RX_RECORD_TOO_LONG -12263 "SSL received a record that exceeded the maximum permissible length." This generally indicates that the remote peer system has a flawed implementation of SSL, and is violating the SSL specification. ```
* self signed cert wit current names   
* ```https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl/27931596#27931596```


- view content of cert
- ```openssl x509 -in ca.pem -text```


# install ping 
- apt-get update && apt-get install iputils-ping


# ERROS
 -  TCP_SWAPFAIL_MISS are when Squid thought it had an object in it's cache
but failed to read it. Squid then falls back on processing the request
as a cache miss.

 - Are you running squid-2.3 with asyncufs? 



 - ERROR: No forward-proxy ports configured.
    - https://wiki.squid-cache.org/KnowledgeBase/NoForwardProxyPorts
    - no intercept port 
    - http://www.squid-cache.org/mail-archive/squid-users/201202/0498.html


- https://forum.ubuntuusers.de/topic/squid-3-und-docker-forwarding-loop-detected-fo/

- no interce
- 



# docu iptables 
- http://www.netfilter.org/documentation/index.html#HOWTO

[iptables pkacket flow](http://www.easy-network.de/iptables.html)

# CHECK IP-FORWARDING

# docu
- https://wiki.squid-cache.org/ConfigExamples/Intercept/LinuxDnat
 
    - net.ipv4.ip_forward = 1
    - cat /proc/sys/net/ipv4/ip_forward

    - net.ipv4.conf.default.rp_filter=0
    - cat /proc/sys/net/ipv4/conf/default/rp_filter

 - 1 for enable

#docu 
https://www.linuxquestions.org/questions/linux-server-73/iptables-for-a-remote-transparent-proxy-946863/
#dsl box

# docu squid debgug code 
http://etutorials.org/Server+Administration/Squid.+The+definitive+guide/Chapter+16.+Debugging+and+Troubleshooting/16.2+Debugging+via+cache.log/


 # routing table
 - ls -lh /etc/iproute2/rt_tables 
 - cat  /etc/iproute2/rt_tables


- list/show
    - routing
    - ```sudo ip route list```
    - rules
    - ```ip rule list```
    - list of rules
    - ```ip route show table main```

- [doku](http://linux-ip.net/html/routing-tables.html)

 - del 
 - ```sudo ip route del default table TRANSDNS```



test proxy 

1) inside docker box
- ./bash_container.sh
- curl --proxy 127.0.0.1:3128 www.tagesschau.de  => TCP_MISS/200 or TCP_REFRESH_MODIFIED/200
- curl --proxy 127.0.0.1:3128 https://www.heise.de  => TCP TUNNEL

2) on host server
- curl --proxy <IP FROM DOCKER CONTAINER>:3128 http://www.tagesschau.de
- curl --proxy $(cat currentContainerIpAddr.txt):3128 http://www.tagesschau.de

- e.g.
- curl --proxy 172.17.0.2:3128 http://www.tagesschau.de  => TCP_MISS/200
 -curl --proxy 172.17.0.2:3128 https://www.tagesschau.de  => TCP_TUNNEL <= proto https



curl --proxy $(cat currentContainerIpAddr.txt):3128 http://www.tagesschau.de
curl --proxy $(cat currentContainerIpAddr.txt):3128 https://www.heise.de

curl -v -s -o - -X OPTIONS https://google.com

curl -v -s -o - -X OPTIONS -proxy $(cat currentContainerIpAddr.txt):3128 https://google.com

curl -v -s -o - -X OPTIONS --proxy $(cat currentContainerIpAddr.txt):3128 https://www.heise.de


funzt:
sudo ./clean-iptables.sh
sudo ./set-transperent-iptables-setting_2.sh










