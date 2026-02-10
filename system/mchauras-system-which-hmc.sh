#!/bin/bash

# Looks in the ~/hmc-managed-systems.txt file to give which hmc has the lpar
# Usage:
#	which-hmc system
#
# Example:
#	which-hmc rain85
#	which-hmc ltcrain85
#
#
#

GET_LIST_CMD=$HOME/scripts/system/mchauras-system-update-hmc-system-list.sh

if [[ "$@" = *"-h"* ]]; then
	echo "USAGE: which-hmc <lpar-name/substring-of-lpar-name> [-f]"
	echo "EXAMPLE: which-hmc ltcever7x3 [-f]"
	echo "-f: Pass any second argument to force refresh of system list"
	exit 1
fi

test -z "$1" && {
	echo "Please provide lpar name\n"
	echo "USAGE: which-hmc <lpar-name/substring-of-lpar-name> [-f]"
	echo "EXAMPLE: which-hmc ltcever7x3"
	exit 1
}
managed_system=$(echo $1 | cut -d'.' -f1 | cut -d'-' -f1)
force=$2
test -n "$force" && $GET_LIST_CMD
hmc="$(grep $managed_system $HOME/.hmc-managed-systems.txt | cut -d':' -f1)"
test -z "$hmc" && test -z "$force" && {
	echo "System not connected to any of the known HMCs. Trying to refresh system list..."
	$GET_LIST_CMD
	hmc="$(grep $managed_system $HOME/.hmc-managed-systems.txt | cut -d':' -f1)"
}
if [[ "$hmc" == "" ]]; then
	echo "System not connected to any of the known HMCs";
	exit 1
else
	echo $hmc.ltc.tadn.ibm.com
fi

