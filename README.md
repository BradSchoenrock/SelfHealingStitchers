Author: Brad Schoenrock 

noSessions.sh Self Healing script 
https://jira.charter.com/browse/VOINTAKE-15588

MarioQAM.sh 
https://jira.charter.com/browse/POSTTRIAGE-19974
----------------------------------------------------------------------------------------------------------
Description:
----------------------------------------------------------------------------------------------------------

The noSessions.sh is a temporary mitigation script that would detect the condition where a stitcher is not processing new sessions. 
The detail steps are described in the iMOP template: https://mop.awas.corp.chartercom.com/mops/129242 
It logs events to cloudtv-alerts.log

The MarioQAm.sh 
Leaking sockets is when the compositor main thread is trying to close a socket still in use by a compositor child thread, 
specifically noticed was the compositor child thread attempting to send data to the local UDC reporting thread which was non responsive
(not sending acks in the socket teardown, i don't recall if this put the socket in TIME_WAIT, CLOSE_WAIT, or FIN_WAIT). 
This leads to the compositor child thread retrying to send its data over and over into a socket no longer in use after the socket eventually times out.
When the socket was attempted to be reused later on the compositor child thread would still be attempting to send data through that socket, 
corrupting whatever data was being sent through that socket. This has caused many different issues including flapping stitchers when the socket attempts
to be reused for stitcher health communication to the csm, failures in UDC reporting (not just compositor but other UDC reporting as well) 
when the socket attempts to be reused for that communication, UnableToStartStreamerApp when the reused socket attempts to be used in session setup, 
and i'm sure other conditions which require the use of a socket without interference. To fix this condition an h5restartall is required in order to clean up
the sockets used by compositor which is managed by a crontab entry that runs every 10 min /root/MarioQAM.sh. 
When we were doing this we noticed compositor was occasionally failing to stop in the h5restartall, hence the separate compositor stop to ensure the script
was successful every time and compositor as well as other processes were brought up cleanly. This process was discussed early on in the 2.16 rollout 
as part of the issues it caused (UDC/UnableToStartStreamerApp/Flapping Stitchers). In this condition the html5client and webkit processes
had successfully completed their teardown, and the leaking socket is in compositor in these cases, not in the html5client process since that process has ended. 


Disclaimer: 
You should always double check the changes done by th script against the iMOP and make sure data is correct.

----------------------------------------------------------------------------------------------------------
Installation Instructions:
----------------------------------------------------------------------------------------------------------

You need to clone the GIT repository: 
git clone git@git01pvdcco.pvdc.co.charter.com:SpecGuideOps/Self-Healing_scripts.git 


----------------------------------------------------------------------------------------------------------
Usage Instructions for noSessions.sh:
----------------------------------------------------------------------------------------------------------


1.  The noSessions.yaml configuration is used to deploy the script noSessions.sh in all stitchers defined in a file
    The noSessions.yaml will:
	- Backup the cronjob file.
    - Copy the noSessions.sh script from workstation to the stitchers defined in a text file.
    - Create a cronjob that will execute the script every hour at the minutes: "9,19,29,39,49,59".

        Steps to deploy the noSessions.sh script in stitchers:
        • Clone the market repository
            git clone git@git01pvdcco.pvdc.co.charter.com:SpecGuideOps/Self-Healing_scripts.git 

        • Change to the directory where you clonned the Self-Healing responsitory in the noSessions directory for example:
                cd /home/<IPA>/Self-Healing_scripts/noSessions

        • Create a file with the list of stitchers fqdn where you want to deploy the script. For example:
        
            $ more sldcla_stitchers
            vca001sldcla.sldc.la.charter.com
            vca002sldcla.sldc.la.charter.com
            vca003sldcla.sldc.la.charter.com
            vca004sldcla.sldc.la.charter.com
            vca005sldcla.sldc.la.charter.com
            vca006sldcla.sldc.la.charter.com
            
        •       Deploy the scrpt via ansible:
 		        ansible-playbook -b noSessions_deploy.yaml -k -i sldcla-stitchers
        •       Make sure no errors are reported for all stitchers (Failed = 0) For example:

     	    PLAY RECAP **************************************************************************************************************
            vca002sldcla.sldc.la.charter.com : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

----------------------------------------------------------------------------------------------------------
Usage Instructions for Backout noSessions deploymen using noSessions_backout.yml playbook:
----------------------------------------------------------------------------------------------------------

	The noSessions_backout.yml playbook will:

 	Restore original cronjob file on stitcher.
	Remove cronjob backup file root_backup on stitcher.
	Remove the noSessions.sh script on the stitcher
	Change to the directory where you clonned the Self-Healing respository in the noSessions directory for example:

	cd /home/<IPA>/Self-Healing_scripts/noSessions

	Deploy the script via ansible:

		ansible-playbook -b noSessions_backout.yml -k -i sldcla-stitchers
	• Make sure no errors are reported for all stitchers (Failed = 0) For example:

    PLAY RECAP *******************************************************************************************
    vca002sldcla.sldc.la.charter.com : ok=4 changed=3 unreachable=0failed=0 skipped=0 rescued=0 ignored=0

----------------------------------------------------------------------------------------------------------
Usage Instructions for MarioQAM.sh:
----------------------------------------------------------------------------------------------------------


2.     The MarioQAM_deploy.yaml confighuration is used to deploy the script noSessions.sh in all stitchers defined in a file
        The noSessions.yaml will:
        Copy the noSessions.sh script from workstation to the stitchers defined in a text file
        Create a cronjob that will execute the script every hour at the minutes: "9,19,29,39,49,59" 
        Steps to deploy the noSessions.sh script in stitchers:
        •       Clone the market repository
                git clone git@git01pvdcco.pvdc.co.charter.com:SpecGuideOps/Self-Healing_scripts.git 
        •       Change to the directory where you clonned the Self-Healing responsitory in the Mario directory for example:
                cd /home/<IPA>/Self-Healing_scripts/Mario
        •       Create a file with the list of stitchers fqdn where you want to deploy the script. For example:
                $ more sldcla_stitchers
                vca001sldcla.sldc.la.charter.com
                vca002sldcla.sldc.la.charter.com
                vca003sldcla.sldc.la.charter.com
                vca004sldcla.sldc.la.charter.com
                vca005sldcla.sldc.la.charter.com
                vca006sldcla.sldc.la.charter.com
        •       Deploy the scrpt via ansible
 		        ansible-playbook -b MarioQAM_deploy.yaml -k -i sldcla_2  
        •       Make sure no errors are reported for all stitchers (Failed = 0) For example:

            PLAY RECAP **************************************************************************************************************
            vca002sldcla.sldc.la.charter.com : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 


----------------------------------------------------------------------------------------------------------
Known issues:
----------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------
Contacts:
----------------------------------------------------------------------------------------------------------

If you have any problems, questions, ideas or suggestions please contact:
Brad.Schoenrock@charter.com
Elizabeth.Villanueva@charter.com
