#!/bin/bash
#
# Log time in jira's DMP - Maintenance & Research
# assuming you wish to log 8 hours each day
# The main work of the script is to 
# figure out which days are weekdays vs. weekends
# and then login and days for the weekdays

## exports my credentials
#. $HOME/.cw-passwd

## hardcoded creds
PP_USER=<CHANGE TO YOUR USER NAME>
PP_PASS=<CHANGE TO YOUR PASSWORD>

## Jira issues for maintenance and new dev
MAINT=TT-2
NEWD=TT-3


WORK=''
###############################################
# change month and year to your required date
###############################################
MONTH='09'
YEAR='2014'
###############################################
###############################################
NUMBER_OF_DAYS=$(cal $MONTH $YEAR | grep -e '[0-9].*'  | awk 'END {print $NF}')
echo " --  $NUMBER_OF_DAYS" 
for DAY in $(seq 1 $NUMBER_OF_DAYS)
do
	#  is that day a weekend?
	DATE_FORMAT="${YEAR}-${MONTH}-${DAY}"
#	echo $DATE_FORMAT
##  # uname could tested for 'Linux' vs. 'Darwin'
##	#############
##	# for linux
##	#############
##	#WHICH_DAY=$(date '+%u' -d $DATE_FORMAT)
##	# check against 6 or 7
##	if [[ "$WHICH_DAY" == '6' || "$WHICH_DAY" == '7' ]]
##	then
##		echo "Weekend! $WHICH_DAY $YEAR-$MONTH-$DAY"
##		WORK="$WORK ${YEAR}-${MONTH}-${DAY},0h,0h"
##	else
##		echo "Weekday! $WHICH_DAY $YEAR-$MONTH-$DAY"
##		WORK="$WORK ${YEAR}-${MONTH}-${DAY},8h,0h"
##	fi

	#############
	# for OSX
	#############
	WHICH_DAY=$(date -v${DAY}d -v${MONTH}m -v${YEAR}y '+%a')
	# check against Sat or Sun
	if [[ "$WHICH_DAY" == 'Sun' || "$WHICH_DAY" == 'Sat' ]]
	then
		echo "Weekend! $WHICH_DAY $YEAR-$MONTH-$DAY"
		WORK="$WORK ${YEAR}-${MONTH}-${DAY},0h,0h"
	else
		echo "Weekday! $WHICH_DAY $YEAR-$MONTH-$DAY"
		WORK="$WORK ${YEAR}-${MONTH}-${DAY},8h,0h"
	fi
	
done
echo $WORK

for ENTRY in $WORK; do

DAY=$(echo "$ENTRY" | cut -d"," -f1 )
TIME_IN_MAINT=$(echo "$ENTRY" | cut -d"," -f2 | tr -d ' ')
TIME_IN_NEWD=$(echo "$ENTRY" | cut -d"," -f3 | tr -d ' ')

if [ "${TIME_IN_MAINT}" != "0h" ]; then
echo "Attempting to log ${TIME_IN_MAINT} on ${DAY} for ${MAINT} for Maintenance"
curl -s -u ${PP_USER}:${PP_PASS} -X POST -d "{\"started\": \"${DAY}T12:00:00.000-0400\", \"timeSpent\": \"${TIME_IN_MAINT}\"}" -H "Content-Type: application/json" "http://jira.pulse.corp/rest/api/2/issue/${MAINT}/worklog"
fi

#if [ "${TIME_IN_NEWD}" != "0h" ]; then
#echo "Attempting to log ${TIME_IN_NEWD} on ${DAY} for ${NEWD} for New Development"
#curl -s -u ${PP_USER}:${PP_PASS} -X POST -d "{\"started\": \"${DAY}T12:00:00.000-0400\", \"timeSpent\": \"${TIME_IN_NEWD}\"}" -H "Content-Type: application/json" "http://jira.pulse.corp/rest/api/2/issue/${NEWD}/worklog"
#fi

done
