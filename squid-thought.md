# thought

## docker run curl

```bash
> docker run -it hiromasaono/curl
> docker run -it hiromasaono/curl curl http://heute.de
```

## copy between host and container

```bash
> docker cp f74cc286:/root/squid3-3.5.23/debian/squid/etc/squid/squid.conf squid.conf.dist
```

```bash
docker run -it hiromasaono/curl curl --proxy 192.168.178.32:80 http://www.tagesschau.de


docker run -it hiromasaono/curl curl http://www.tagesschau.de

```

## squid status code

```bash
> squid -k debug -f /var/local/squid/squid.conf
```

[see here for cli command](http://etutorials.org/Server+Administration/Squid.+The+definitive+guide/Chapter+5.+Running+Squid/5.1+Squid+Command-Line+Options/)

[here](http://squid-handbuch.de/hb/node104_mn.html)

## squid BUGReporting and debug tcpdump

[SQUID bug reporting](https://wiki.squid-cache.org/SquidFaq/BugReporting)

[Squid 3.5: Preventing forwarding loop in intercept mode](https://serverfault.com/questions/743977/squid-3-5-preventing-forwarding-loop-in-intercept-mode)


## iptables inside docker container

- iptables v1.4.21: can't initialize iptables table `nat': Permission denied (you must be root)

- [from here](https://github.com/moby/moby/issues/4424)
```bash
--cap-add=NET_ADMIN
v.s.
--privileged
```

## benchmark / performance

- marked packet and route  vs. iptables redirect

## show iptables rules from container on the host

## routing inside container => composer, kubernetes
