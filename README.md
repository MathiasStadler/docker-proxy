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

