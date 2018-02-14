#!/bin/bash

# from here
# https://wiki.squid-cache.org/SquidFaq/BugReporting#Debugging_a_single_transaction

# your proxy IP (docker container)
SQUIDIP=$(cat .currentContainerIpAddr.txt)
echo -e "SQUIDIP => $SQUIDIP"

# your proxy listening port
SQUIDPORT=3128
# SQUIDPORT=3129
echo -e "SQUIDPORT => $SQUIDPORT"

interface="docker0"
echo -e "interface => $interface"

# bash_command="sudo tcpdump -s 0 -i ${interface} -w /tmp/squid-to-example.com.pcap port $SQUIDPORT and host $SQUIDIP"


# where -G specifies rotation interval in seconds, and the flexible string like %Y-%m-%d_%H:%M:%S in filename exposes to date (man strftime) when the rotation occurred
# bash_command="sudo tcpdump -s 0 -i ${interface} -G 300 -w /tmp/squid-to-client100-%Y-%m-%d_%H:%M:%S.pcap port $SQUIDPORT and host $SQUIDIP"

bash_command="sudo tcpdump -s 0 -i ${interface} port $SQUIDPORT"

# from here
# https://www.cyberciti.biz/tips/shell-scripting-bash-how-to-create-temporary-random-file-name.html
tmp_cmd_file="$(mktemp /tmp/bash_command_XXXXXX)"
echo -e "Execute command => ${bash_command}"
echo -e "#!/bin/bash" >"${tmp_cmd_file}"
echo -e "echo \"interrupt with [ctrl]+c\"" >>"${tmp_cmd_file}"
echo -e "$bash_command 2>&1 >${tmp_cmd_file}_output" >>"${tmp_cmd_file}"
chmod +x "${tmp_cmd_file}"
output=$("${tmp_cmd_file}")
result="$?"
set +x # undo command echoing
if [ "$result" -ne 0 ]; then
    echo -e "\033[01;33;41mOught please fix your command $output\033[0m"
else
    echo -e "\033[00;32m Command was ok $result\033[0m"
fi
set -x