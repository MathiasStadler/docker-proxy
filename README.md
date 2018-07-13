# docker-proxy

- My copy of [silarsis/docker-proxy](https://github.com/silarsis/docker-proxy) with my config

## edit squid.conf

- vi squid.conf
- build docker images new
- docker build -t docker-proxy .

## DOCKER build behind proxy

- add --build-arg http_proxy= YOUR-PROXY-IP:PORT
- sample

```bash
docker build --build-arg http_proxy=http://192.168.178.32:3128 -t mathiasstatdler/postgres .
```

- [from here](https://github.com/docker/docker-registry/issues/890)
- Credits to Anders [Janmyr](https://github.com/andersjanmyr) for this Idea

## ERROR Connection rest by cliant

- ERROR was rised by SQUID DOCKER WGET during the build process
- add --enable-http-violations to squid.patch
- add

```bash
via off
forwarded_for delete
```

## HOWTO Exclude Few Sites from Caching

- [from here](https://aacable.wordpress.com/2012/01/23/squid-howto-exclude-some-sites-exntension-from-caching/)

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

/_ spell-checker: disable _/

```bash
bankalhabib.com
aacable.wordpress.com
wordpress.com
nae.com.pk
jang.com.pk
```

/_ spell-checker: enable _/

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

```bash
openssl s_client -connect 192.168.178.32:443 -state -debug
```

## install ping

```bash
apt-get update && apt-get install iputils-ping
```

## instll dig

```bash
sudo apt-get install dnsutils
```

## install editor vim

```bash
echo "deb-src http://security.ubuntu.com/ubuntu/ xenial-security main restricted" >>/etc/apt/sources.list
apt-get update
apt-get install vim
```

## documentation squid debug code

[see here](http://etutorials.org/Server+Administration/Squid.+The+definitive+guide/Chapter+16.+Debugging+and+Troubleshooting/16.2+Debugging+via+cache.log/)

<!-- markdownlint-disable MD034 -->

## test proxy

- inside docker box
- login to image ./bash_container.sh
- curl --proxy 127.0.0.1:3128 www.tagesschau.de => TCP_MISS/200 or TCP_REFRESH_MODIFIED/200
- curl --proxy 127.0.0.1:3128 https://www.heise.de => TCP TUNNEL

- on host server where docker run
- curl --proxy IP_FROM_DOCKER_CONTAINER:3128 http://www.tagesschau.de
- e.g.
- curl --proxy $(cat currentContainerIpAddr.txt):3128 http://www.tagesschau.de
- curl --proxy $(cat currentContainerIpAddr.txt):3128 http://www.tagesschau.de
- curl --proxy $(cat currentContainerIpAddr.txt):3128 https://www.heise.de

## see header of request

curl -v -s -o --proxy $(cat currentContainerIpAddr.txt):3128 https://github.com

<!-- markdownlint-enable MD034 -->
