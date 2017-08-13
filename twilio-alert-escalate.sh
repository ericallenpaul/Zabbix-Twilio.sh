#!/bin/bash

#get the current weeknumber
weeknumber=`date +%V` 

# get the person on next weeks call list
weeknumber=$((weeknumber+1))

function usage
{
	if [ -n "$1" ]; then echo $1; fi
	echo "Usage: twilio-alert-escalate.sh [-v] [-c configfile]"
	exit 1
}

# set to verbose by default
VERBOSE=0

# get the current script directory
DIRECTORY=$(cd `dirname $0` && pwd)

# create a path to the default config file
CONFIGFILE="$DIRECTORY/twilio-alert.conf"

# create a schedule path
PHONEFILE="$DIRECTORY/Schedule/${weeknumber}"

# check the command line options
while getopts ":c:v" opt; do
	case "$opt" in
		c) CONFIGFILE=$OPTARG ;;
		v) VERBOSE=1 ;;
		*) echo "Unknown param: $opt"; usage ;;
	esac
done

# test configfile
if [ -n "$CONFIGFILE" -a ! -f "$CONFIGFILE" ]; then echo "Configfile not found: $CONFIGFILE"; usage; fi

# source configfile
if [ "$VERBOSE" -eq 1 ]; then echo "Reading twilio-alert.conf..."; fi
if [ -n "$CONFIGFILE" ]; then . "$CONFIGFILE"; fi

# get the phone number
if [ "$UseWeeklySchedule" -eq 1 ];
then
	PHONENUMBER=$(cat $PHONEFILE)
else
	PHONENUMBER="$OnCallNumber"
fi

echo "$1" | $DIRECTORY/twilio-sms.sh -c $DIRECTORY/twilio-sms.conf $PHONENUMBER

echo ok
