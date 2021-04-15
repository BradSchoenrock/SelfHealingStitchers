#!/bin/bash

myList=()

#compares the snmp info to the netstat result to determine number of streams going out
compare () {
	varone=$(snmpget -v2c -c public localhost 1.3.6.1.4.1.1192.1.1.1.4.0 | sed -n 's/.*Gauge32: \(.*\)$/\1/p')
	vartwo=$(netstat -nputw | grep udp | grep compositor | sort | grep -v 127.0.0 | wc -l)

	echo "snmp reports $varone"
	echo "netstat reports $vartwo"

	if [ $vartwo -gt $((2*$varone)) ] 
	then
		#panic! 
		return 2
	elif [ $varone -ne $vartwo ]
	then
        	# slow problem, long check	
		return 1
	else
		# no problem.
		return 0
	fi
}



# checks current netstat list to last netstat list and keeps only sessions that were previously active
# to let us know if there is a single continuous session. If the list gets to zero length (has no entries)
# program will exit. Checks if entries are in list by checking for a ":" character, which seperates 
# port and IP in  
writeList () {
	#echo "hey"
		
	netstatResult=$(netstat -nputw | grep udp | grep compositor | sort | grep -v 127.0.0 | tr -s ' ' | cut -d " " -f 5)
	#echo "before loop"
	#echo $netstatResult
	tmplist=()
	for entry in $netstatResult
	do
		#echo "entry=$entry"
		for entry2 in $myList
		do
			#echo "entry2=$entry2"
			if [ ${entry} == ${entry2} ]
			then
				#echo "equal"
				tmplist+="${entry} "
			fi
		done
	done
	eval myList=($(printf "%q\n" "${tmplist[@]}" | sort -u))
	tmpStr=":"
	if [[ ${myList} != *${tmpStr}* ]]
	then
		#echo "exiting"
		#echo $myList	
		exit
	fi
	
}



# 
restartFast () {

# check time of day, if between 15:00 and 21:00 UTC (9-3 mountain time) do automatic restarts.
# log and emails sent here to inform team of any action taken or detection outside of restart hours.
# 9-3 was settled upon since ghost sessions spawn at night, and we don't want to restart in PT.
# known problem where snmp over-reports the number of sessions may lead to missing ghost sessions.
currenttime=$(date +%H:%M)
        
echo "$(date) Mario has detected leaky pipes at ${currenttime}. snmpwalk reports $varone active streams. netstat reports $vartwo active streams. h5restartall automatically performed." > /var/log/cloudtv-alerts.log

export https_proxy=http://98.9.227.108:8080   

curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) $(hostname) Mario has detected leaky pipes at ${currenttime}. snmpwalk reports $varone active streams. netstat reports $vartwo active streams. h5restartall automatically performed.\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    

systemctl stop compositor

h5restartall

sleep 3s

exit

}


# Checks for persistant mismatch in compositor streams vs number of active sessions. Restarts if daytime. 
restartSlow () {

# check time of day, if between 15:00 and 21:00 UTC (9-3 mountain time) do automatic restarts.
# log and emails sent here to inform team of any action taken or detection outside of restart hours.
# 9-3 was settled upon since ghost sessions spawn at night, and we don't want to restart in PT.
# known problem where snmp over-reports the number of sessions may lead to missing ghost sessions.
currenttime=$(date +%H:%M)
if [[ "$currenttime" > "15:00" ]] && [[ "$currenttime" < "21:00" ]]
then
    echo "$(date) pacman detected a ghost session at ${currenttime}. snmpwalk reports $varone active streams. netstat reports $vartwo active streams. h5restartall automatically performed." > /var/log/cloudtv-alerts.log

    export https_proxy=http://98.9.227.108:8080   

    curl -X POST -H "Content-Type: application/json" -d "{\"text\" : \"$(date) $(hostname) pacman detected a ghost session at ${currenttime}. snmpwalk reports $varone active streams. netstat reports $vartwo active streams. h5restartall automatically performed.\"}" "https://webexapis.com/v1/webhooks/incoming/Y2lzY29zcGFyazovL3VzL1dFQkhPT0svMTZlODJkN2MtYWIxYS00MDZjLWJkNjQtZTc0ZjQ2ZWIzOGZm"    


	systemctl stop compositor
	
	h5restartall

fi

sleep 3s

exit

}



###################start###################

# initial setup of myList which holds list of IP Ports being broadcast
myList=$(netstat -nputw | grep udp | grep compositor | sort | grep -v 127.0.0 | tr -s ' ' | cut -d " " -f 5)

#echo $myList

# run once per 10 sec for 10 min. Exit if snmp and netstat match or just restart right away if the number of outgoing streams is 2x the number of active sessions. 
for i in {1..60}
do
	compare
	Result=$?
	#echo "start of itteration"
	echo "Result=$Result"
	if [ $Result -eq 2 ]
	then
		#panic! 
		restartFast
	elif [ $Result -eq 1 ]
	then
		# slow continue checks
		writeList
		#echo "myList:"
		#echo $myList
		sleep 10s
	elif [ $Result -eq 0 ]
	then
		# no trouble found
		exit
	fi	
done

restartSlow


