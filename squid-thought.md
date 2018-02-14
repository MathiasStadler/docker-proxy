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