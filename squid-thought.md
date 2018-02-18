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

## curl unknown protocol

- curl: (35) error:140770FC:SSL routines:SSL23_GET_SERVER_HELLO:unknown protocol

## curl --cacert

```bash
curl --cacert non_existing_file https://www.google.com
```

```bash
curl -v -sS -o /dev/null https://httpbin.org/get
```

## TODO npm pip

- Some programs **don't** use the OS's primary key store, such as npm and pip. You may need to take extra steps for those programs.


## curl

- curl: (4) OpenSSL was built without SSLv2 support


## see header from request and response

```bash
#~~~~~~~~~ snip of squid.conf ~~~~~~~~~~~~~~~
debug_options  ALL,1 11,2 74,9,93,3
#logformat squid %tg.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %[un %Sh/%<a %mt
#access_log /var/log/squid/access.log squid


# <Client IP> <Username> [<Local Time>] "<Request Method> <Request URL> HTTP/<Protocol Version> <Response Status Code> \
# <Sent reply size (with hdrs)> <Referer> <User Agent> <Squid Request Status>:<Squid Hierarchy Status>
logformat combined %>a %un [%tl] "%rm %ru HTTP/%rv" %>Hs %<st "%{Referer}>h" "%{User-Agent}>h" %Ss:%Sh
access_log /var/log/squid/squid.log squid
access_log /var/log/squid/access.log combined

#~~~~~~~~~ snip of squid.conf ~~~~~~~~~~~~~~~
```

## chiper setting http://squid-web-proxy-cache.1019090.n4.nabble.com/Help-troubleshooting-proxy-lt-gt-client-https-td4682583.html


## to know

- [from here] http://squid-web-proxy-cache.1019090.n4.nabble.com/Help-troubleshooting-proxy-lt-gt-client-https-td4682583.html

```bash
http_port 3128
# HTTP-over-TCP
# HTTPS-over-TCP (aka HTTP-over-TLS-over-TCP)

https_port 3129
# HTTP-over-TLS   (aka HTTP-over-TLS-over-TCP)
# HTTPS-over-TLS (aka HTTP-over-TLS-over-TLS-over-TCP)
```


## curl opsenssl error

see here SSL23_GET_SERVER_HELLO instead ServerHello

[see here](https://stackoverflow.com/questions/15166950/unable-to-establish-ssl-connection-how-do-i-fix-my-ssl-cert)

```bash
#check cert from remote host
openssl s_client -connect httpbin.org:443


```

## SECURITY ALERT: Host header forgery detected on (intercepted port does not match 443)

- [see here ](https://wiki.squid-cache.org/KnowledgeBase/HostHeaderForgery)

```bash
2018/02/16 15:58:57.351 kid1| SECURITY ALERT: Host header forgery detected on local=172.17.0.2:3130 remote=172.17.0.1:45430 FD 36 flags=33 (intercepted port does not match 443)
```

## logformat combined
[see here](http://www.squid-cache.org/Doc/config/logformat/)

## E2guardian Web filtering
- pfsence
- snort
- ids
- squid gard


## error language
 error_default_language de-de
<http://master.squid-cache.org/Doc/config/error_default_language/>


## always_direct allow all

[see here](http://lists.squid-cache.org/pipermail/squid-users/2017-May/015467.html)

```text
That "always_direct" was a hack to workaround a bug in the first
ssl-bump code. It is long since irrelevant. I recommend removing it.
```

## For the redirector debug_options 61,5

## Squid 3 is only listening only on IPv6

[netstat squid3](http://blogs.barlow.uk.net/techblog/squid-3-listening-ipv6/)

```bash
# install netstat
> apt-get install -y net-tools

# check port
# you should only see the expose port
> sudo netstat -antp
```

```bash
#squid.conf

#listen on tcp6
http_port 3128

#listen on tcp4
http_port 0.0.0.0:3128
```

## insatll netstat


# acl manager proto manager

```text
manager" ACL is now built-in. You can remove that incorrect definition.
```


## another thread

http://squid-web-proxy-cache.1019090.n4.nabble.com/squid-3-5-24-Host-header-forgery-detected-td4681692.html

```text
> sslproxy_cert_error allow all
> sslproxy_flags DONT_VERIFY_PEER

Please remove the above. I really cannot stress enough how bad it is. It
completely and utterly removes all security from HTTPS.

DONT_VERIFY_PEER is of almost zero benefit and allows several whole
classes of attacks to be performed (completely invisibly to you and your
client) by *other* people attacking your Internet connections. Then
"sslproxy_cert_error allow all" forbids Squid from informing anybody
(including you!) about anything suspicious Squid might still be able to
detect.

Yes errors will happen in TLS/SSL. You *need* to know what those are,
and for that you *need* Squid to be doing the peer/server verification.

_Some_ errors can be ignored when used by certain servers. That is what
sslproxy_cert_error exists for. Use it sparingly.

```



http://squid-web-proxy-cache.1019090.n4.nabble.com/squid-3-5-24-Host-header-forgery-detected-td4681692.html

https://wiki.squid-cache.org/KnowledgeBase/HostHeaderForgery



## install dig

```bash
sudo apt-get install dnsutils
```


## install vi/vim

```bash
sudo apt-get install vim
```


## dns problem behind a proxy
https://unix.stackexchange.com/questions/212897/nslookup-dig-firefox-ignoring-etc-hosts-file-entries

- mainly
https://unix.stackexchange.com/questions/158419/browsers-doesnt-see-an-aliases-in-etc-hosts


## Without that information all traffic will get a 409 HTTP error and log this alert.

[from here](https://wiki.squid-cache.org/KnowledgeBase/HostHeaderForgery)

```text
ensure that NAT is performed on the same box as Squid.

    Squid MUST have access to the NAT systems records of what the original destination IP was. **Without that information all traffic will get a 409 HTTP error and log this alert.**

    When operating Squid on a different machine to your router use Policy Routing or a tunnel to deliver traffic to squid. Do not perform destination NAT (DNAT, REDIRECT, Port Forwarding) on the router machine before the traffic hits Squid.
```

## policy routing

[overview blog entry](https://blog.scottlowe.org/2013/05/29/a-quick-introduction-to-linux-policy-routing/
)


