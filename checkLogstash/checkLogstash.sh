#!/bin/bash

nLogstash=$(ps -ef | grep logstash | grep -v grep | wc -l)

if (( $nLogstash != 1 ))
then
    systemctl restart logstash
    
    echo "(date) logstash crashed, automatically restarted logstash." > /var/log/cloudtv-alerts.log
        
    export https_proxy=http://98.9.227.108:8080   

    curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) logstash crashed, automatically restarted logstash on $(hostname).\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    

fi

