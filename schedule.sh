#!/bin/bash

function usage
{
	if [ -n "$1" ]; then echo $1; fi
	echo "Usage: schedule.sh [-v] [-c configfile]"
	exit 1
}

function checkargs()
{
	if [ $1 -lt 1 ];
	then
			echo "You must supply an argument for the config file" 
			usage
			exit 1
	fi
}


# set to verbose by default
VERBOSE=0

#get the current script directory
DIRECTORY=$(cd `dirname $0` && pwd)

# create a path to the default config file
CONFIGFILE="$DIRECTORY/schedule.conf"

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

if [ "$VERBOSE" -eq 1 ]; then echo "Done reading config file."; fi

SCHEDULEDIR="$DIRECTORY/Schedule" 

if [ "$VERBOSE" -eq 1 ]; then echo "Create the schedule directory..."; fi

mkdir -p "$SCHEDULEDIR"

if [ "$VERBOSE" -eq 1 ]; then echo "CD to the schedule directory..."; fi
cd "$SCHEDULEDIR"

COUNTER=0

if [ "$VERBOSE" -eq 1 ]; then echo "Get the list of On Call numbers from the config..."; fi
IFS=',' read -ra PHONE <<< "$OnCallNumbers"

for i in {1..52} 
do

	if [ "$VERBOSE" -eq 1 ]; then echo "Adding ${PHONE[$COUNTER]} as the number for week $i"; fi
	echo -n ${PHONE[$COUNTER]} > $i
	
	((COUNTER++))

	if [ $COUNTER -eq ${#PHONE[@]-1} ];
	then
		COUNTER=0
	fi

done
if [ "$VERBOSE" -eq 1 ]; then echo "Schedule creation complete."; fi