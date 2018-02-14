#!/bin/bash

# from here
# https://stackoverflow.com/questions/8455991/elegant-way-for-verbose-mode-in-scripts
# set verbose level to info

# set default log_level
readonly __VERBOSE=7

# loglevels
declare -A LOG_LEVELS
# https://en.wikipedia.org/wiki/Syslog#Severity_level
# TODO old not more used LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")

# function .log
# return nothing
function .log () {
  local LEVEL=${1}
  shift
  if [ ${__VERBOSE} -ge "${LEVEL}" ]; then
    # echo -e "[${LOG_LEVELS[$LEVEL]}]" "$@"
	echo -e "$@"
  fi
}

# follow idea from here
# https://github.com/armbian/build/blob/master/lib/general.sh

log()
#--------------------------------------------------------------------------------------------------------------------------------
# Let's have unique way of displaying alerts
#--------------------------------------------------------------------------------------------------------------------------------
{

# set default _log_level for messages
let _log_level=6

# check is 2nd  message set
if [ "$3" ]
then
  # TODO old .log 7 "3rd function argument  => \"$3\" is not null."
  _log_level=$3
else
  # TODO old .log 7 "3rd function argument  =>\"$3\" <= is null."
  _log_level=$1
fi

	# log function parameters to install.log
	#[[ -n $DEST ]] && echo "Displaying message: $@" >> $DEST/debug/output.log

	local log_message=""
	[[ -n $2 ]] && log_message="[\e[0;33m $2 \x1B[0m]"

	# TODO old case $3 in
	case "${_log_level}" in

		emerg)
		.log 0 "[\e[0;31m emerg \x1B[0m] $log_message"
		;;
		alert)
		.log 1 "[\e[0;31m alert \x1B[0m] $log_message"
		;;
		critical)
		.log 2 "[\e[0;31m critcal \x1B[0m] $log_message"
		;;
		error)
		.log 3 "[\e[0;31m error \x1B[0m] $log_message"
		;;
		warning)
		.log 4 "[\e[0;35m warning \x1B[0m] $log_message"
		;;
		notice)
		.log 5  "[\e[0;32m notice \x1B[0m] $log_message"
		;;
		info)
		.log 6 "[\e[0;32m info \x1B[0m] $log_message"
		;;
		debug)
		.log 7 "[\e[0;32m debug \x1B[0m] $log_message"
		;;
		*)
		.log 6 "[\e[0;32m info \x1B[0m] $1 $log_message"
		;;
	esac
}

.log 6 "Start logging"

function show_looging(){

# .log 1 "0"
# .log 1 "1"
# .log 2 "2"
# .log 3 "3"
# .log 4 "4"
# .log 5 "5"
# .log 6 "6"
# .log 7 "7"

# log "0" "emerg"
# log "1" "alert"
# log "2" "critical"
# log "3" "error"
# log "4" "warning"
# log "5" "notice"
# log "6" "info"
# log "7" "debug"

log "emerg" "emerg message"
log "alert" "alert message"
log "critical" "critical message"
log  "error" "error message"
log  "warning" "warning message"
log  "notice" "notice message"
log  "info" "info message"
log  "debug" "debug message"

# log "0" "emerg with text" "emerg"
# log "1" "alert with text" "alert"
# log "2" "critical with text" "critical"
# log "3" "error with text" "error"
# log "4" "warning with text" "warning"
# log "5" "notice with text" "notice"
# log "6" "info with text" "info"
# log "7" "debug with text" "debug"

#LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")

}

# avoid overwrite the SCRIPT_NAME value at export to other script
readonly SCRIPT_NAME="bash_log_helper.sh"

function  usage_bash_log_helper(){
echo -e "Script  $(basename "$0") call directly"
echo -e "Helper script should run normaly as bash include"
echo -e "BASH_PATH_HELPER=$(basename "$0"); test -f \$BASH_PATH_HELPER && source \$BASH_PATH_HELPER"
}

if [[ $(basename "$0") == "${SCRIPT_NAME}" ]]; then
	usage_bash_log_helper
	show_looging
	exit 0
fi

# from here
# https://unix.stackexchange.com/questions/104755/how-can-i-create-a-local-function-in-my-bashrc
unset -f usage_bash_log_helper