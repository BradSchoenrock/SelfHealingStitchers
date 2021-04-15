#!/bin/bash


echo "hello world $(date)"

now10=$(($(date +%s) - (10 * 60)))

StartStream=$(cat $(ls /var/log/cloudtv.log* | grep -v "gz") | grep "starting stream")
SessionEnter=$(cat $(ls /var/log/cloudtv.log* | grep -v "gz") | grep "session-enter" | grep "lsm")

# printf %s "$StartStream"
NStartStream=0
while read -r line; do 
	[ $(date -d "${line:0:19}" +%s) -gt $now10 ] && NStartStream=$(($NStartStream + 1))
done <<< "$StartStream"

# printf %s "$SessionEnter"
NSessionEnter=0
while read -r line; do 
	[ $(date -d "${line:0:19}" +%s) -gt $now10 ] && NSessionEnter=$(($NSessionEnter + 1))
done <<< "$SessionEnter"

echo "NStartStream last 10 min = $NStartStream"
echo "NSessionEnter last 10 min = $NSessionEnter"

if [ $NStartStream -eq 0 ] && [ $NSessionEnter -gt 10 ]
then
	echo "$(date) No streams started out of $NSessionEnter session enter attempts in the past 10 minutes." > /var/log/cloudtv-alerts.log 
	export https_proxy=http://98.9.227.108:8080   
    curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) No streams started out of $NSessionEnter session enter attempts in the past 10 minutes. $(hostname)\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    

	h5restartall
fi


echo "goodbye world $(date)" 
