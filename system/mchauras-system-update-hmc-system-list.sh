#!/bin/bash

# Update locally cached hmc-managed-systems list
# 
# Usage: update-hmc-system-list
#
# We can periodically run it, or just before using 'which-hmc' command, so to
# have updated list
PCAJET_PASSWD=$(cat $HOME/.pcajet)
managed_systems_file="$HOME/.hmc-managed-systems.txt"

if ! command -v sshpass &> /dev/null
then
	echo "sshpass is not installed. Please install it to use this"
	exit
fi

if [[ -z "$PCAJET_PASSWD" ]]; then
	echo "No valid PCAJET_PASSWORD"
	exit
fi

for v in {1..11}; do
	echo "Fetching managed systems for ltcvhmc$v..."
	# Timout after 5s, instead of failing at it
	sshpass -p $PCAJET_PASSWD ssh -o ConnectTimeout=5 -o LogLevel=ERROR \
	-o StrictHostKeyChecking=no hscroot@ltcvhmc$v.onecloud.stglabs.ibm.com "true"

	if [[ $? -eq 5 ]]; then
		echo "$PCAJET_PASSWD is invalid"
		mv $HOME/.pcajet $HOME/.pcajet.invalid
		exit 5
	fi
	managed_systems=$( \
		sshpass -p $PCAJET_PASSWD \
		ssh -o ConnectTimeout=5 -o LogLevel=ERROR \
		-o StrictHostKeyChecking=no hscroot@ltcvhmc$v.onecloud.stglabs.ibm.com "lssyscfg -r sys -F name" | sed 's/\r$//')

	test -n "$managed_systems" && {
		sed -i -e "/ltcvhmc$v/d" $managed_systems_file
		printf "ltcvhmc$v:" >> $managed_systems_file
		echo $managed_systems | while read sys; do
			printf " $sys" >> $managed_systems_file
		done
		printf "\n" >> $managed_systems_file
	}
done

