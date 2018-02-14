#!/bin/bash

# TODO is port 53 free eg is used from dnsmasq

BASH_PATH_HELPER=./bash_helper/bash_log_helper.sh
test -f $BASH_PATH_HELPER && source $BASH_PATH_HELPER

ROUTINGTABLE="TRANSPROXY"

CACHEDIR=${CACHEDIR:-${PWD}/data/cache}
CERTDIR=${CERTDIR:-${PWD}/data/ssl}
CONTAINER_NAME=${CONTAINER_NAME:-docker-proxy}
CONFDIR=${CONFDIR:-${PWD}}
LOGDIR=${LOGDIR:-${PWD}/log}

#set env
GIT_OWNER_NAME=$(git config user.name | tr '[:upper:]' '[:lower:]')
BASH_OWNER_NAME=$(id -u -n)
OWNER_NAME=${GIT_OWNER_NAME:-$BASH_OWNER_NAME}
CONTAINER_NAME=${CONTAINER_NAME:-c-docker-unbound}
IMAGES_NAME=${IMAGES_NAME:-i-docker-proxy}
TAG_NAME=${TAG_NAME:-latest}
SERVER_KEYS_DIR=unbound_control_keys
OUTPUT_UNBOUND_CONTROL_SETUP=output_unbound-control-setup.txt

# DNS_PORT=53
# DNS_PROXY_PORT=53

# getopts
while getopts ":n" opt; do
    case $opt in
    n)
        echo "-n delete images " >&2
        CREATE_NEW_IMAGES=yes
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 0
        ;;
    esac
done

#exit on error
set -e

start_routing() {

    log "info" "start routing"

    # Add a new route table that routes everything marked through the new container
    # workaround boot2docker issue #367
    # https://github.com/boot2docker/boot2docker/issues/367

    [ -d /etc/iproute2 ] || sudo mkdir -p /etc/iproute2
    if [ ! -e /etc/iproute2/rt_tables ]; then
        if [ -f /usr/local/etc/rt_tables ]; then
            sudo ln -s /usr/local/etc/rt_tables /etc/iproute2/rt_tables
        elif [ -f /usr/local/etc/iproute2/rt_tables ]; then
            sudo ln -s /usr/local/etc/iproute2/rt_tables /etc/iproute2/rt_tables
        fi
    fi

    log "info" "add  ROUTINGTABLE ${ROUTINGTABLE} /etc/iproute2/rt_tables"

    ([ -e /etc/iproute2/rt_tables ] && grep -q "${ROUTINGTABLE}" /etc/iproute2/rt_tables) ||
        sudo sh -c "echo '1	$ROUTINGTABLE' >> /etc/iproute2/rt_tables"

    ip rule show | grep -q "{$ROUTINGTABLE}" ||
        sudo ip rule add from all fwmark 0x1 lookup "${ROUTINGTABLE}"

    sudo ip route add default via "${IPADDR}" dev docker0 table "${ROUTINGTABLE}"

    # Mark packets to port 80 and 443 external, so they route through the new
    # route table

    COMMON_RULES="-t mangle -I PREROUTING -p tcp -i docker0 ! -s ${IPADDR}
      -j MARK --set-mark 1"

    # TODO old dns approach
    #COMMON_RULES="-t nat -A OUTPUT -p udp --dport ${DNS_PORT} -j DNAT --to ${IPADDR}:${DNS_PROXY_PORT}"
    #echo "Redirecting DNS to docker-"

    COMMON_RULES="-t mangle -I PREROUTING -p tcp -i docker0 ! -s ${IPADDR}
    -j MARK --set-mark 1"

    log "info" "Redirecting HTTP to docker-proxy"

    sudo iptables "${COMMON_RULES}" --dport 80

    log "info" "set iptables rule iptables ${COMMON_RULES}"

    if [ "$WITH_SSL" = 'yes' ]; then
        log "info" "Redirecting HTTPS to  $CONTAINER_NAME"
        sudo iptables "${COMMON_RULES}" --dport 443
        log "info" "set iptables rule iptables ${COMMON_RULES}"
    else
        log "info" "Not redirecting HTTPS. To enable, re-run with the argument 'ssl'"
        log "info" "CA certificate will be generated anyway, but it won't be used"
    fi



    # Exemption rule to stop docker from masquerading traffic routed to the
    # transparent proxy
    sudo iptables -t nat -I POSTROUTING -o docker0 -s 172.17.0.0/16 -j ACCEPT
}

stop_routing() {
    # Remove iptables rules.
    set +e


    log "info" "Delete default route from table ${ROUTINGTABLE}"
    ip route show table "$ROUTINGTABLE" | grep -q default &&
        sudo ip route del default table "${ROUTINGTABLE}"

    log "info" " Delete all rules from ip rule "
    sudo ip rule show | grep ${ROUTINGTABLE} | cut -d: -f1 | xargs -r -L1 sudo ip rule del prio

    # TODO check if real all deleted

    while true; do
        rule_num=$(sudo iptables -t mangle -L PREROUTING -n --line-numbers |
            grep -E 'MARK.*172\.17.*tcp \S+ MARK set 0x1' |
            awk '{print $1}' |
            head -n1)
        sudo iptables -t mangle -D PREROUTING "${rule_num}"
        log "notice" "Delete iptables rule"
        log "info" "iptables -t mangle -D PREROUTING ${rule_num}"
    done
    COMMON_RULES="-t nat -D POSTROUTING -o docker0 -s 172.17.0.0/16 -j ACCEPT"
    sudo iptables "${COMMON_RULES}" 2>/dev/null
    set -e
}

showAllUsedPort() {
    # from here
    # https://askubuntu.com/questions/699508/how-to-extract-mapped-ports-from-docker-pss-output
    sudo docker ps | awk -F" {2,}" 'END {print $6}'
}

createRemoteKeys() {

    log "info" "delete keys..."
    rm -rf ./*key ./*pem
    log "info" o "create new keys..."
    if "$(pwd)"/unbound-control-setup.sh -d ${SERVER_KEYS_DIR} >/tmp/${OUTPUT_UNBOUND_CONTROL_SETUP}; then
        log "info" o "Keys generated...OK"
        rm -rf /tmp/${OUTPUT_UNBOUND_CONTROL_SETUP}
    else
        log "info" o "ERROR during execution"
        log "info" o "Please see output file !!!...Not OK"
        cat /tmp/${OUTPUT_UNBOUND_CONTROL_SETUP}
        exit 1
    fi
}

checkKeysForRemoteControl() {
    if ls -l | grep -q ${SERVER_KEYS_DIR}; then
        log "info" o "Directory ${SERVER_KEYS_DIR} available"
        #any files inside directory
        # TODO old SC2126 nItems="$(ls -1 --file-type ${SERVER_KEYS_DIR} | grep -v '/$' | wc -l)"
        nItems="$(ls -1 --file-type ${SERVER_KEYS_DIR} | grep -c '/$')"
        if [ "${nItems}" = "0" ]; then
            log "info" o "dir ${SERVER_KEYS_DIR} is empty, no files inside ..."
            createRemoteKeys
        else
            log "info" o "=> ${SERVER_KEYS_DIR}"
            #nKeys="$(ls -l ${SERVER_KEYS_DIR}/*key | grep -c "${SERVER_KEYS_DIR}/*key")"
            # TODO old SC2126 nKeys="$(ls -1 --file-type ${SERVER_KEYS_DIR} | grep key | grep -v '/$' | wc -l)"
            nKeys="$(ls -1 --file-type ${SERVER_KEYS_DIR} | grep key | grep -c '/$')"
            log "info" o "${nKeys}"
            if [ "${nKeys}" = "2" ]; then
                log "info" o "${nKeys}/2 key fond...OK"
            else
                log "info" o "${nKeys}/2 key fond...Not Ok"
                createRemoteKeys
            fi
            #nPems="$(ls -l ${SERVER_KEYS_DIR}/*pem | grep -c "${SERVER_KEYS_DIR}/*pem")"
            # TODO old SC2126 nPems="$(ls -1 --file-type ${SERVER_KEYS_DIR} | grep pem | grep -v '/$' | wc -l)"
            nPems="$(ls -1 --file-type ${SERVER_KEYS_DIR} | grep pem | grep -c '/$')"
            if [ "${nPems}" = "2" ]; then
                log "info" o "${nPems}/ 2 key fond...OK"
            else
                log "info" o "${nPems}/ 2 key fond...Not OK"
                createRemoteKeys
            fi
        fi
    else
        log "info" o "Directory ${SERVER_KEYS_DIR} NOT available, create new one..."
        mkdir -p ${SERVER_KEYS_DIR}
        touch .gitkeep
        createRemoteKeys
    fi
}

checkRunningContainerAndStop() {

    log "info" "check is container running"
    if docker ps | grep -q "${OWNER_NAME}/${IMAGES_NAME}"; then
        #TODO What is if we found more than container ?
        log "info" "$(docker ps | grep -c "${OWNER_NAME}/${IMAGES_NAME}") running Container found ... $(docker ps | grep "${OWNER_NAME}/${IMAGES_NAME}" | awk '{print $1}')"
        read -r -p "Would you like stop this container now ? Think on your Production  [y/N]" response
        case "$response" in [yY][eE][sS] | [yY])
            log "info" "stopping container now ..."
            docker ps | grep "${OWNER_NAME}/${IMAGES_NAME}" | awk '{print $1}' | xargs --no-run-if-empty docker stop >/dev/null
            ;;
        *)
            log "info" "This container is still running ..."
            docker ps | grep "${OWNER_NAME}/${IMAGES_NAME}" | grep "${CONTAINER_NAME}" | grep "${TAG_NAME}"
            log "info" "Have fun with it...ciao"
            exit 0
            ;;
        esac

    else

        log "warn" "No container ${OWNER_NAME}/${IMAGES_NAME} running!...OK"
    fi
}

copyConfigFileForBuild() {

    #copy default scripts
    cp squid-config/mime.conf current
    #TODO old cp squid-config/squid.conf current
    cp squid-config/start_squid.sh current

    #copy customer settings
    cp squid-config/not-to-cache-sites.txt current
    cp squid-config/self-signed-cert.conf current

}

checkImagesAndBuildNewIfNecessary() {

    copyConfigFileForBuild

    if [ "$CREATE_NEW_IMAGES" = 'yes' ]; then
        #check images is available
        if docker images "${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME}" | grep -q "${OWNER_NAME}/${IMAGES_NAME}"; then
            log "info" "Delete current images  ${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME}"
            docker rmi "${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME}"
        else
            log "info" "Images ${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME} no found...OK"
            log "info" "Nothing to do !...OK"
        fi
    fi
    if docker images "${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME}" | grep -q "${OWNER_NAME}/${IMAGES_NAME}"; then
        log "info" "Images ${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME} exists...OK"
    else
        log "info" "Images ${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME} doesn't exist"
        read -r -p "Would you like build this images now ? [y/N]" response
        case "$response" in [yY][eE][sS] | [yY])
            log "info" "start build images ${OWNER_NAME}/${IMAGES_NAME} "
            log "info" "docker build --tag ${OWNER_NAME}/${IMAGES_NAME} --file current/Dockerfile ."
            docker build --tag "${OWNER_NAME}/${IMAGES_NAME}" --file current/Dockerfile "$(pwd)"/current
            ;;
        *)
            log "info" "Without the images can you not start the docker container!"
            log "info" "Rerun the script and choice yes for build the images ...ciao"
            exit 0
            ;;
        esac
    fi
}

deleteOldContainer() {

    # check created container
    # we want use always new container
    # TODO is that stupid ???

    log "info" "We would start a new Container"
    log "info" "Check old container available .."

    if docker ps -a | grep "${CONTAINER_NAME}"; then
        log "info" "$(docker ps -a | grep -c "${CONTAINER_NAME}") ${CONTAINER_NAME} container found"
        log "info" "We delete the container now ... "
        docker ps -a | grep "${CONTAINER_NAME}" | awk '{print $1}' | xargs --no-run-if-empty docker rm
        if docker ps -a | grep "${CONTAINER_NAME}"; then
            log "info" " Error we couldnt delete the container ${CONTAINER_NAME} ...Not OK"
            exit 1
        else
            log "info" "All ${CONTAINER_NAME} container deleted...OK"
        fi
    else
        log "info" "No ${CONTAINER_NAME} container found for deleted...OK"
    fi
}

runContainer() {
    log "info" "run container ..."
    log "info" "Used ${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME} to start new ${CONTAINER_NAME} container"
    #start container
    #TODO old
    #   CID=$(docker run --name "${CONTAINER_NAME}" -d \
    #       -v "$(pwd)"/a-records.conf:/opt/unbound/etc/unbound/a-records.conf:ro \
    #       -v "$(pwd)"/root.hints:/opt/unbound/etc/unbound/root.hints:ro \
    #       -v "$(pwd)"/unbound_control_keys/unbound_server.key:/opt/unbound/etc/unbound/unbound_server.key:ro \
    #       -v "$(pwd)"/unbound_control_keys/unbound_server.pem:/opt/unbound/etc/unbound/unbound_server.pem:ro \
    #       -v "$(pwd)"/unbound_control_keys/unbound_control.key:/opt/unbound/etc/unbound/unbound_control.key:ro \
    #       -v "$(pwd)"/unbound_control_keys/unbound_control.pem:/opt/unbound/etc/unbound/unbound_control.pem:ro \
    #       "${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME}")

    CID=$(sudo docker run -d \
        --name "${CONTAINER_NAME}" \
        --volume="${CACHEDIR}":/var/cache/squid:rw \
        --volume="${CERTDIR}":/etc/squid/ssl_cert:rw \
        --volume="${CONFDIR}":/var/local/squid:ro \
        --volume="${LOGDIR}":/var/log/squid:rw \
        --hostname "${CONTAINER_NAME}" \
        "${OWNER_NAME}/${IMAGES_NAME}:${TAG_NAME}")

    IPADDR=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${CID}")

    echo "${IPADDR}" >.currentContainerIpAddr.txt

    start_routing

    #only for convenience see README.md
    echo "${CID}" >.currentContainer.id

    # give docker two seconds
    # TODO check docker is ready
    sleep 2

    if docker ps | grep "${OWNER_NAME}/${IMAGES_NAME}" | grep "${CONTAINER_NAME}" | grep -q "${TAG_NAME}"; then
        log "info" "Container ${OWNER_NAME}/${CONTAINER_NAME}:${TAG_NAME} with $(log "info" "${CID}" | head -c 12) running...Ok"
    else
        log "error" "Error container no coming up...Not Ok"
    fi
}

stopContainer() {
    log "info" "stop container ${CONTAINER_NAME}"
    set +e
    sudo docker rm -fv "${CID}" >/dev/null 2>&1
    set -e
    stop_routing

}

interrupted() {
    log "info" 'Interrupted, cleaning up...'
    trap - INT
    stopContainer
    kill -INT $$
}

terminated() {
    log "info" 'Terminated, cleaning up...'
    trap - TERM
    stopContainer
    kill -TERM $$
}

main() {
    log "info" "run"
    # TODO old
    #checkKeysForRemoteControl
    checkRunningContainerAndStop
    deleteOldContainer
    checkImagesAndBuildNewIfNecessary
    runContainer

    # Run at console, kill cleanly if ctrl-c is hit
    trap interrupted INT
    trap terminated TERM
    sudo docker logs -f "${CID}"
    log "info" 'Squid exited unexpectedly, cleaning up...'
    stopContainer

}

main
log "info" "done"
