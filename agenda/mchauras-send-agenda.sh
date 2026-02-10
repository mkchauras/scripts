#!/bin/bash

# Define variables
subject="Agenda at `date`"
recipient="mkchauras@gmail.com"
cc_recipients="-c mukeshmike9@gmail.com -c mukesh.chaurasiya@ibm.com -c mukesh@mchauras.com"
file_to_send="$HOME/.agenda.html"
body="Agenda for the month is:
`cat $file_to_send`
"
# Use mutt to send the email
#echo "$body" | /usr/bin/mailx -s "$subject" $cc_recipients -a $file_to_send -C "Content-Type: text/html" $recipient
echo "$body" | /usr/bin/mailx -s "$subject" $cc_recipients -C "Content-Type: text/html" $recipient
#echo "$body" | /usr/bin/mailx -s "$subject" $cc_recipients $recipient

