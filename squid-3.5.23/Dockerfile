#FROM ubuntu:14.04
#update to
FROM ubuntu:latest

ENV DH_VERBOSE=1 

MAINTAINER Kevin Littlejohn <kevin@littlejohn.id.au>, \
    Alex Fraser <alex@vpac-innovations.com.au>

# Install base dependencies.
WORKDIR /root
RUN export DEBIAN_FRONTEND=noninteractive TERM=linux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        dpkg-dev \
        iptables \
        libssl-dev \
        wget \
        patch \
        squid-langpack \
        ssl-cert \
        sudo \
        build-essential \
        #from here
        #https://github.com/shadowsocks/shadowsocks-libev/issues/1344
        # thx Ixyu
        debhelper/xenial-backports \
        dh-make \ 
        quilt \ 
        fakeroot \
        lintian \
        logrotate \
        libdbi-perl \
        iproute2 \
        #required for 
        #dpkg-gencontrol: warning: File::FcntlLock not available; using flock which is not NFS-safe
        libfile-fcntllock-perl
    
    RUN cat /etc/apt/sources.list \ 
    #from here
    # https://bugs.launchpad.net/ubuntu/+source/aptitude/+bug/1543280/comments/27
&& adduser --force-badname --system --home /nonexistent --no-create-home --quiet _apt || true \
&& getent passwd _apt \
&& mkdir -p /var/lib/update-notifier/package-data-downloads/partial/   \
&& chown _apt /var/lib/update-notifier/package-data-downloads/partial/ \
&& chmod 777 /var/lib/update-notifier/package-data-downloads/partial/ \
&& ls -la /var/lib/update-notifier/package-data-downloads/ \
&& chmod 777 /root \


#from here 
# http://ccm.net/faq/809-debian-apt-get-no-pubkey-gpg-error
    && gpg --keyserver pgpkeys.mit.edu --recv-key  8B48AD6246925553   \
    &&  gpg -a --export 8B48AD6246925553 | sudo apt-key add - \
    && gpg --keyserver pgpkeys.mit.edu --recv-key  7638D0442B90D010   \
    &&  gpg -a --export 7638D0442B90D010 | sudo apt-key add - \
    && gpg --keyserver pgpkeys.mit.edu --recv-key  EF0F382A1A7B6500   \
    &&  gpg -a --export EF0F382A1A7B6500 | sudo apt-key add - \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 2BA97CED D876D5A3 \
    && gpg --no-default-keyring -a --export 2BA97CED D876D5A3  | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import -  \
    && echo "deb-src ftp://ftp.de.debian.org/debian/ stable main contrib" >>/etc/apt/sources.list  \
    # from here
    # https://github.com/shadowsocks/shadowsocks-libev/issues/1264
    #&& echo "deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse" >>/etc/apt/sources.list  \
    && echo $PWD \
    && apt-get update \
    && apt-get source -y squid3 squid-langpack \
    && echo $PWD \
    && id \
    && ls -la \
    && ls -la /var/lib/update-notifier/package-data-downloads/ \
    && apt-get build-dep -y squid3 squid-langpack


#install debian openssl 
#why see here
#Error SSL_ERROR_RX_RECORD_TOO_LONG
#http://squid-web-proxy-cache.1019090.n4.nabble.com/Squid-with-SSL-Bump-on-Debian-testing-SSL-ERROR-RX-RECORD-TOO-LONG-td4681683.html






#create openssl.conf
RUN touch /etc/ssl/opensll.cnf \
#from here
#http://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpExplicit
COPY openssl.cnf  /etc/ssl/openssl.cnf
# Customise and build Squid.
# It's silly, but run dpkg-buildpackage again if it fails the first time. This
# is needed because sometimes the `configure` script is busy when building in
# Docker after autoconf sets its mode +x.
COPY squid3.patch mime.conf /root/
RUN ls -la \
    && id \
    #FIX add ? for squid 3.5.23
    && cd squid3-3.?.?? \
    && ls -la debian \
    && cat debian/rules \
    #from here fix patch
    #http://www.markusbe.de/2009/12/wie-man-einen-patch-anwendet-und-hunk-failed-cant-find-file-to-patch-und-andere-loest/#hunk-failed
    && patch -p1 < /root/squid3.patch \
    #&& patch -Np1 --ignore-whitespace < /root/squid3.patch \
    && export NUM_PROCS=`grep -c ^processor /proc/cpuinfo` \
    
    #&& (dpkg-buildpackage -b -j${NUM_PROCS} \
    #    || dpkg-buildpackage -b -j${NUM_PROCS}) \
    # change to without sign in
    # from here
    # https://serverfault.com/questions/191785/how-can-i-properly-sign-a-package-i-modified-and-recompiled
     && (dpkg-buildpackage -b -uc -us -j${NUM_PROCS} \
        || dpkg-buildpackage -b -uc -us -j${NUM_PROCS}) 

#FIX add ? for squid 3.5.23
RUN  ls -la \
&& DEBIAN_FRONTEND=noninteractive TERM=linux dpkg -i \
    #    ../squid3-common_3.?.??-?ubuntu?.?_all.deb \
    #    ../squid3_3.?.??-?ubuntu?.?_*.deb \
    #  next line should match squid-common_3.5.23-5_all.deb
                           ./squid-common_3.?.??-?_all.deb \
    #  next line should match squid_3.5.23-5_amd64.deb
                           ./squid_3.?.??-?_amd64.deb \
    && mkdir -p /etc/squid/ssl_cert \
    && mkdir -p /usr/share/squid \
    && cat /root/mime.conf >> /usr/share/squid/mime.conf \
    
    && mkdir -p /var/cache/squid \
    && touch /var/cache/squid/ssl_db \
    #FIX ADD for dumping
    && mkdir -p /var/cache/squid \
    && chown -R proxy:proxy /var/cache/squid  \
    #TODO check again is /var/cache/squid in used 
   && mkdir -p /squid/var/cache/squid \
   && mkdir -p /squid/var/cache/squid \
   && chown -R proxy:proxy /squid/var/cache/squid  
   # /usr/local/squid/etc/
   # && mkdir -p /usr/local/squid/etc/ \
   # && touch 


#TODO  ADD would not work why ??
RUN wget http://ftp.openssl.org/source/openssl-1.0.2l.tar.gz \
&&  tar -xzf openssl-1.0.2l.tar.gz  \   
&& cd openssl* \
&& ./config  --prefix=/usr --libdir=lib --openssldir=/etc/ssl shared zlib-dynamic  \
&& make \
&& make test \
&& make install




# RUN export DEBIAN_FRONTEND=noninteractive TERM=linux \
#      && apt-get purge -y  \
#         debhelper/xenial-backports \
#         dh-make \ 
#         quilt \ 
#         fakeroot \
#         lintian \
#         logrotate \
#         libdbi-perl \
#         iproute2 


#FIX to squid    
#COPY squid.conf /etc/squid/squid.conf

RUN mkdir -p /var/local/squid
#COPY not-to-cache-sites.txt /etc/squid/not-to-cache-sites.txt

#start script of container
COPY start_squid.sh /usr/local/bin/start_squid.sh


COPY self-signed-cert.conf /usr/local/bin/self-signed-cert.conf

#FIX to squid
VOLUME /var/spool/squid /etc/squid/ssl_cert
EXPOSE 3128 3129 3130


RUN rm -rf /etc/squid/squid.conf

CMD ["/usr/local/bin/start_squid.sh"]
