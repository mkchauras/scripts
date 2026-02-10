#!/bin/bash

# Function to display usage
show_help() {
	echo "Usage: addtask <deadline> <task>"
	echo "  <deadline>      Number of days until the deadline"
	echo "                  must be a positive integer(0 for Today)"
	echo "                  OR DDD format e.g. Mon, Tue etc"
	echo "  <task>          Description of the task"
	exit 1
}

# Check if two arguments are passed
if [ "$#" -ne 2 ]; then
	show_help
fi

# Assign arguments to variables
deadline_day="$1"
task="$2"

# Check if deadline_day is a valid number
if ! [[ "$deadline_day" =~ ^[0-9]+$ ]]; then

	# Try to calculate the next occurrence of the specified day
	deadline_date=$(date -d "next $deadline_day" +"%Y-%m-%d %a" 2>/dev/null)

	# Check if the date command was successful
	if ! [ $? -eq 0 ]; then
		echo -e "Error: Incorrect Deadline\n"
		show_help
	fi
else
	# Get the future date based on the deadline day
	deadline_date=$(date -d "+$deadline_day days" +"%Y-%m-%d %a")
fi


# Print the outputdd
echo "$task: $deadline_date"


# Path to the Org file
ORG_FILE="$HOME/scripts/agenda/agenda.org"

echo -e "** TODO $task" >> $ORG_FILE
echo -e "DEADLINE: <${deadline_date}>\n" >> $ORG_FILE


#$HOME/scripts/agenda/mukesh-get-agenda.sh > /dev/null &
