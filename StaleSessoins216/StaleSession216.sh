#!/bin/bash

# run this hourly. 

proc1=$(ps -C html5client-v3 -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]-)
proc2=$(ps -C WebKitWebProces -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]-)
proc3=$(ps -C WebKitNetworkProcess -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]-)

if [ ${#proc1} -ne 0 ] 
then

	echo "$(date) Stale Session Detected. process killed. ${proc1}" > /var/log/cloudtv-alerts.log

    export https_proxy=http://98.9.227.108:8080   
    curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) Stale Session Detected. $(hostname) process killed. ${proc1}\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    

    kill -15 $(ps -C html5client-v3 -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]- | tr -s ' ' | cut -d " " -f 4)	
    sleep 3s
	kill -9 $(ps -C html5client-v3 -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]- | tr -s ' ' | cut -d " " -f 4)

fi

if [ ${#proc2} -ne 0 ]
then

    echo "$(date) Stale Session Detected. process killed. ${proc2}" > /var/log/cloudtv-alerts.log
    export https_proxy=http://98.9.227.108:8080   
	curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) Stale Session Detected. $(hostname) process killed. ${proc2}\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    

	kill -15 $(ps -C html5client-v3 -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]- | tr -s ' ' | cut -d " " -f 4)
	sleep 3s
    kill -9 $(ps -C WebKitWebProces -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]- | tr -s ' ' | cut -d " " -f 4)

fi

if [ ${#proc3} -ne 0 ]
then

    echo "$(date) Stale Session Detected. process killed. ${proc3}" > /var/log/cloudtv-alerts.log
    export https_proxy=http://98.9.227.108:8080   
    curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) Stale Session Detected. $(hostname) process killed. ${proc3}\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    

    kill -15 $(ps -C html5client-v3 -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]- | tr -s ' ' | cut -d " " -f 4)
	sleep 3s
    kill -9 $(ps -C WebKitNetworkProcess -o start,pid,etime,cmd,pcpu,rss,size | grep [0-9]- | tr -s ' ' | cut -d " " -f 4)

fi



