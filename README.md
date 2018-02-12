# docker-proxy

- My copy of silarsis/docker-proxy with my config 

## edit squid.conf

- vi squid.conf
- build docker images new
- docker build  -t docker-proxy .

## DOCKER build behind proxy

- add --build-arg http_proxy=http://192.168.178.32:3128
* sample ```docker build --build-arg http_proxy=http://192.168.178.32:3128 -t mathiasstatdler/postgres .```
* from here  https://github.com/docker/docker-registry/issues/890
    - thx Anders Janmyr for the Idea <https://github.com/andersjanmyr>


# ERROR Connection rest by cliant 
- ERROR was rised by SQUID DOCKER WGET during the build process 
    - add --enable-http-violations  to squid.patch
    - add ``` via off
forwarded_for delete ```

## Howto Exclude Few Sites from Caching

-  [from here](https://aacable.wordpress.com/2012/01/23/squid-howto-exclude-some-sites-exntension-from-caching/)

- add squid.conf

```bash
acl NO-CACHE-SITES dstdomain "/etc/squid/not-to-cache-sites.txt"
no_cache deny NO-CACHE-SITES
acl sharing_server dst 10.0.0.1
cache deny sharing_server
```

- Now create the file which will contains our sites list which we don’t want to cache.

```bash
vi /etc/squid/not-to-cache-sites.txt
```

- add following or your entries

```bash
bankalhabib.com
aacable.wordpress.com
wordpress.com
nae.com.pk
jang.com.pk
```

- Credits goes to Kevin Littlejohn

## helps

- enter container

```bash
docker exec -it $(cat currentSquidContainer.id) /bin/bash
```

- copy kez

```bash
docker cp $(cat currentSquidContainer.id):/etc/squid/ssl_cert/ca.der .
``` 

- delete old cert new are create than by the next start
```bash
docker exec -it  $(cat currentSquidContainer.id) rm /etc/squid/ssl_cert/ca.pem
```

## debug openssl

``` bash
openssl s_client -connect 192.168.178.32:443 -state -debug
```

- [from here](https://forum.ubuntuusers.de/topic/ssl-error-rx-record-too-long/)
- ``` http://www.mozilla.org/projects/secur.html#1040263 sagt zu deiner Firefoxmeldung:
    SL_ERROR_RX_RECORD_TOO_LONG -12263 "SSL received a record that exceeded the maximum permissible length." This generally indicates that the remote peer system has a flawed implementation of SSL, and is violating the SSL specification. ```
* self signed cert wit current names   
* ```https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl/27931596#27931596```


- view content of cert
- ```openssl x509 -in ca.pem -text```

## install pincurl -v -s -o  --proxy $(cat currentContainerIpAddr.txt):3128 https://www.heise.deg 
- apt-get update && apt-get install iputils-ping



#docu 
https://www.linuxquestions.org/questions/linux-server-73/iptables-for-a-remote-transparent-proxy-946863/
#dsl box

# docu squid debgug code 
http://etutorials.org/Server+Administration/Squid.+The+definitive+guide/Chapter+16.+Debugging+and+Troubleshooting/16.2+Debugging+via+cache.log/


## test proxy 

- inside docker box
- login to image ./bash_container.sh
- curl --proxy 127.0.0.1:3128 www.tagesschau.de  => TCP_MISS/200 or TCP_REFRESH_MODIFIED/200
- curl --proxy 127.0.0.1:3128 https://www.heise.de  => TCP TUNNEL

- on host server where docker run
- curl --proxy IP_FROM_DOCKER_CONTAINER:3128 http://www.tagesschau.de
- e.g.
- curl --proxy $(cat currentContainerIpAddr.txt):3128 http://www.tagesschau.de
- curl --proxy $(cat currentContainerIpAddr.txt):3128 http://www.tagesschau.de
- curl --proxy $(cat currentContainerIpAddr.txt):3128 https://www.heise.de


# see header of request
curl -v -s -o  --proxy $(cat currentContainerIpAddr.txt):3128 https://github.com
