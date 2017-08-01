#!/bin/bash

function gen-cert() {
    #FIX squid3 to squid 
    pushd /etc/squid/ssl_cert > /dev/null
    if [ ! -f ca.pem ]; then
        openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes \
            -x509 -keyout privkey.pem -out ca.pem \
            -subj '/CN=docker-proxy/O=NULL/C=AU'
        chown proxy.proxy privkey.pem
        chmod 600 privkey.pem
        openssl x509 -in ca.pem -outform DER -out ca.der
        #ad cert
        openssl req -new -newkey rsa:1024 -days 1365 -nodes -x509 -keyout myca.pem -out myCA.pem
        chown proxy.proxy  myCA.pem
    else
        echo "Reusing existing certificate"
    fi
    openssl x509 -sha1 -in ca.pem -noout -fingerprint
    # Make CA certificate available for download via HTTP Forwarding port
    # e.g. GET http://docker-proxy:3128/squid-internal-static/icons/ca.pem

    #FIX add mkdir -p
    #FIX to squid
    mkdir -p /usr/share/squid/icons/
    cp `pwd`/ca.* /usr/share/squid/icons/
    popd > /dev/null
    return $?
}

function start-routing() {
    # Setup the NAT rule that enables transparent proxying
    IPADDR=$(/sbin/ip -o -f inet addr show eth0 | awk '{ sub(/\/.+/,"",$4); print $4 }')
    echo "IPADDR (start_squid.sh)=>  ${IPADDR}"
    return $?
}

function init-cache() {
    # Make sure our cache is setup
    touch /var/log/squid/access.log /var/log/squid/cache.log
    #FIX to squid
    chown proxy.proxy -R /var/spool/squid /var/log/squid
    [ -e /var/spool/squid/swap.state ] || squid3 -z 2>/dev/null
}

gen-cert || exit 1
start-routing || exit 1
init-cache
#squid -z
/usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db
chown -R proxy.proxy /var/lib/ssl_db
squid
tail -f /var/log/squid/access.log /var/log/squid/cache.log
