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