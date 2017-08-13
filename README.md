# Zabbix-Twilio.sh 
This is a set of scripts that will allow you to send SMS messages for zabbix alerts using twilio. It will also allow you to use a rotating weekely schedule.

Part of these scripts come straight from an example provided by Twilio. If you aren't familiar with [Twilio](https://www.twilio.com) you should check them out. They are the least expensinve and most reliable option for sending SMS messages.
I have included their scripts here as a convienience but you may want to get them directly from the [source](https://www.twilio.com/labs/bash/sms)
I only made some small modifications to their orginal script. I added a line ``echo $RESPONSE >> twilio_response.log``
I renamed the files to make them more consistent with my own naming convention.
Many of the scripts are almost duplicacated wiht a few minor changes. This makes them easier to work with in Zabbix.

## The scripts
##### schedule.sh
This script creates the schedule based on the list of phone numbers in ``schedule.conf``.
This script creates a Schedule directory. It creates 52 files (one for each week of the year) and cycles through the comma delimited list of phone numbers in the schedule.conf and adds a number to each file. To manually make changes to the schedule simply edit the file and change the phone number.

##### twilio-alert.sh
This is the primary script for sending the alerts. Edit the ``twilio-alert.conf`` file and add your phone number and weekly schedule prefrence. If you set ``UseWeeklySchedule = 0`` then the schedule is ignored and all alerts go to the "OnCallNumber"

##### twilio-alert-escalate.sh
This script should only be used when ``UseWeeklySchedule = 1``. It is designed to use in a zabbix [escalation](https://www.zabbix.com/documentation/3.2/manual/config/notifications/action/escalations). It will figure out who is on call next and send the message to them. This could be used in a scenario like "If "on call tech" doesn't acknowledge alert within 15 minutes then escalate to "next on call tech". 

##### twilio-alert-notify.sh
If you want to notify the next "on call tech" that they are about to go on call create a cron job that runs this script. It will only execute on Sunday regardless of what day it's run. (Unix weeks start on Monday, so Sunday is the end of the week) It will send a message like:
```
You will be on call tomorrow (08/14/17) at 12:01 AM. Please plan to respond to any alerts for the next 7 days.
```

### Installation
1. Copy these scripts into your zabbix alert scripts folder (normally located in ``/usr/lib/zabbix/alertscripts``)
2. Edit the twilio-sms.conf file and include your twilio sid, account token and phone number. Test the twilio-sms script to make sure it works:
```
 echo "TEST" | /usr/lib/zabbix/alertscripts/twilio-sms.sh -c /usr/lib/zabbix/alertscripts/twilio-sms.conf 5555555555
```
3. Edit the schedule.conf file and run ``schedule.sh -v``
4. Change the owner and group of all scripts and directories to zabbix. 

	```chown -R zabbix:zabbix /usr/lib/zabbix/alertscripts```
    
5. Create your media type in Zabbix and point it at the script
6. Create an action that uses your new media type
7. Create an escalation media type and assign it to the ``twilio-alert-escalate.sh`` script. [optional]
8. Create a cronjob to run ``twilio-alert-notify.sh`` [optional]

_Note: If you edit these files in windows you may be adding windows "returns" to the ends of the lines.
Windows defines a new line with "\r\n" unix systems just use "\n". This is easily remidied with:_

```
tr -d '\r' < infile > outfile
``` 