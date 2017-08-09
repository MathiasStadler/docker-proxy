#!/bin/bash
#
# Script to maintain ip rules on the host when starting up a transparent
# proxy server for docker.

CACHEDIR=${CACHEDIR:-/var/lib/docker-proxy/cache}
CERTDIR=${CERTDIR:-/var/lib/docker-proxy/ssl}
CONTAINER_NAME=${CONTAINER_NAME:-docker-proxy}
if [ "$1" = 'ssl' ]; then
    WITH_SSL=yes
else
    WITH_SSL=no
fi

set -e

sudo docker images | grep -q "^${CONTAINER_NAME} " \
    || (echo "Build ${CONTAINER_NAME} image first" && exit 1)

start_routing () {
  echo "start_routing"

  }

stop_routing () {
   
   echo "stop routing"
}

stop () {
  set +e
  sudo docker rm -fv ${CONTAINER_NAME} >/dev/null 2>&1
  set -e
  stop_routing
}

interrupted () {
  echo 'Interrupted, cleaning up...'
  trap - INT
  stop
  kill -INT $$
}

terminated () {
  echo 'Terminated, cleaning up...'
  trap - TERM
  stop
  kill -TERM $$
}


start (){

#FIX /var/spool/squid to   /var/cache/squid
CID=$(sudo docker run --privileged -d \
        --name ${CONTAINER_NAME} \
        --volume="${CACHEDIR}":/var/cache/squid \
        --volume="${CERTDIR}":/etc/squid/ssl_cert \
        --publish=3128:3128 \
        --publish=3129:3129 \
        --publish=3130:3130 \
--net host \
        ${CONTAINER_NAME})

#ADD write for convienience  
echo "${CID}" >./currentSquidContainer.id

}



start1 () {


CID=$(sudo docker run --net host -d docker-proxy)
    }

run () {
  # Make sure we have a cache dir - if you're running in vbox you should
  # probably map this through to the host machine for persistence
  mkdir -p "${CACHEDIR}" "${CERTDIR}"
  # Because we're named, make sure the container doesn't already exist
  stop
  # Run and find the IP for the running container. Bind the forward proxy port
  # so clients can get the CA certificate.
  # #Add port 3130
  
  start



  IPADDR=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID})
  start_routing
  # Run at console, kill cleanly if ctrl-c is hit
  trap interrupted INT
  trap terminated TERM
  echo 'Now entering wait, please hit "ctrl-c" to kill proxy and undo routing'
  sudo docker logs -f "${CID}"
  echo 'Squid exited unexpectedly, cleaning up...'
  stop
}

run
echo
