#!/bin/bash

#get the current weeknumber
weeknumber=`date +%V` 
day=`date +%A | tr '[:upper:]' '[:lower:]'`

# get the person on next weeks call list
notifyweeknumber=$((weeknumber+1))

# if today is sunday

function usage
{
	if [ -n "$1" ]; then echo $1; fi
	echo "Usage: twilio-alert-notify.sh [-v] [-c configfile]"
	exit 1
}

# set to verbose by default
VERBOSE=0

# get the current script directory
DIRECTORY=$(cd `dirname $0` && pwd)

# create a path to the default config file
CONFIGFILE="$DIRECTORY/twilio-alert.conf"

# create a schedule path
PHONEFILE="$DIRECTORY/Schedule/${notifyweeknumber}"

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
if [ "$VERBOSE" -eq 1 ]; then echo "Reading schedule.conf..."; fi
if [ -n "$CONFIGFILE" ]; then . "$CONFIGFILE"; fi

# check to see if this is the notify day
# if not exit

if [ "$VERBOSE" -eq 1 ]; then echo "Checking to see if this is the notify day..."; fi
if [ $day = "sunday" ]
then
    if [ "$VERBOSE" -eq 1 ]; then echo "Today is the day for notification..."; fi
    # get the phone number
    if [ "$UseWeeklySchedule" -eq 1 ];
    then
        PHONENUMBER=$(cat $PHONEFILE)
    else
        PHONENUMBER="$OnCallNumber"
    fi

    tomorrow=`date --date="-1 days ago" +%m/%d/%y`
    message="You will be on call tomorrow ($tomorrow) at 12:01 AM. Please plan to respond to any alerts for the next 7 days.";
echo "$message"
    echo "$message" | $DIRECTORY/twilio-sms.sh -c $DIRECTORY/twilio-sms.conf $PHONENUMBER

    echo ok
else
    if [ "$VERBOSE" -eq 1 ]; then echo "Today is not the notify day, exiting..."; fi
    echo ok
    exit;
fi





