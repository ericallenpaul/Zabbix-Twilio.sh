#!/bin/bash
#####################################################################
#
# Copyright (c) 2010 Twilio, Inc.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
######################################################################

function usage
{
	if [ -n "$1" ]; then echo $1; fi
	echo "Usage: twilio-sms [-v] [-c configfile] [-d callerid] [-u accountsid] [-p authtoken] number [number[number[...]]]"
	exit 1
}

VERBOSE=0

while getopts ":c:u:p:d:v" opt; do
	case "$opt" in
		c) CONFIGFILE=$OPTARG ;;
		d) CALLERID_ARG=$OPTARG ;;
		u) ACCOUNTSID_ARG=$OPTARG ;;
		p) AUTHTOKEN_ARG=$OPTARG ;;
		v) VERBOSE=1 ;;
		*) echo "Unknown param: $opt"; usage ;;
	esac
done

# test configfile
if [ -n "$CONFIGFILE" -a ! -f "$CONFIGFILE" ]; then echo "Configfile not found: $CONFIGFILE"; usage; fi

# source configfile if given
if [ -n "$CONFIGFILE" ]; then . "$CONFIGFILE";
# source the default ~/.twiliorc if it exists
elif [ -f ~/.twiliorc ]; then . ~/.twiliorc;
fi

# if ACCOUNTSID, AUTHTOKEN, or CALLERID were given in the commandline, then override that in the configfile
if [ -n "$ACCOUNTSID_ARG" ]; then ACCOUNTSID=$ACCOUNTSID_ARG; fi
if [ -n "$AUTHTOKEN_ARG" ]; then AUTHTOKEN=$AUTHTOKEN_ARG; fi
if [ -n "$CALLERID_ARG" ]; then CALLERID=$CALLERID_ARG; fi
	
# verify params
if [ -z "$ACCOUNTSID" ]; then usage "AccountSid not set, it must be provided in the config file, or on the command line."; fi;
if [ -z "$AUTHTOKEN" ]; then usage "AuthToken not set, it must be provided in the config file, or on the command line."; fi;
if [ -z "$CALLERID" ]; then usage "CallerID not set, it must be provided in the config file, or on the command line."; fi;

# Get message from stdin, taking only first 160 chars
MSG=`cat`
MSG=${MSG:0:160}

# Verify MSG
if [ -z "$MSG" ]; then usage "No content for the SMS was read from STDIN."; fi;

# for each remaining shell arg, that's a phone number to call
for PHONE in "${@:$OPTIND}"; do
	echo -n "Sending SMS to $PHONE from $CALLERID..."
	# initiate a curl request to the Twilio REST API, to begin a phone call to that number
	RESPONSE=`curl -fSs -u "$ACCOUNTSID:$AUTHTOKEN" -d "From=$CALLERID" -d "To=$PHONE" -d "Body=$MSG" "https://api.twilio.com/2010-04-01/Accounts/$ACCOUNTSID/Messages" 2>&1`
	echo $RESPONSE >> twilio_response.log
	if [ $? -gt 0 ]; then echo "Failed to send SMS to $PHONE: $RESPONSE"
	else echo "ok"
	fi
	if [ "$VERBOSE" -eq 1 ]; then echo $RESPONSE; fi
done

