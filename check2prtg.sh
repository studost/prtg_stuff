#!/bin/bash
#    ____  ____  ____________
#   / __ \/ __ \/_  __/ ____/
#  / /_/ / /_/ / / / / / __  
# / ____/ _, _/ / / / /_/ /  
#/_/   /_/ |_| /_/  \____/                         
#    NETWORK MONITOR
#-------------------
#(c) 2016 Dariusz Gorka, Paessler AG
#
#This script checks if a certain service is running.
#The script also tries to restart the service if it is not started.
#

#Enter the correct process name. (ps -e)
service=$1
#Enter the server address of your PRTG, including HTTPS/HTTP and the sensor port.
prtghost=$2
#Enter the Identification Token of the HTTP Push Data Advanced sensor.
identtoken=$3

#Check if process is running
if (( $(pgrep -x $service | wc -l) > 0 ))
  then
    #Send response to PRTG that the service is running.
    wget -O/dev/null "$prtghost/$identtoken?content=<prtg><result><channel>$service status</channel><value>1</value></result><text>Service: $service is running!</text></prtg>"
  else
    #Send response to PRTG that the service is not started.
    wget -O/dev/null "$prtghost/$identtoken?content=<prtg><result><channel>$service status</channel><value>0</value></result><text>Service: $service is down, but will restart!</text></prtg>"
    #Try to restart the service
    /etc/init.d/$service start

    #Check if restart was successfully
    if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
      then
        #Send response to PRTG that the restart was successfully
        wget -O/dev/null "$prtghost/$identtoken?content=<prtg><result><channel>$service status</channel><value>1</value></result><text>Service: $service restarted properly!</text></prtg>"
      else
        #Send response to PRTG that the restart was not succesfully
        wget -O/dev/null "$prtghost/$identtoken?content=<prtg><result><channel>$service status</channel><value>0</value></result><text>Service: $service can't restart properly! Please take action!</text></prtg>"
      fi
fi

The next step is to create the following CRONTAB on your Linux server to use the script.

To open the CRONTAB file, enter the command "crontab -e", as root, and paste the code on the last line.
*/5 * * * * /PATH/TO/THESCRIPT/script.sh <SERVICENAME> <PRTGHOST> <IDENT-TOKEN>

Please keep in mind to adjust the path and the parameters of the crontab, like the examples below!

<SERVICENAME>: snmpd
<PRTGHOST>: https://prtg.paessler.com:5050 (please use the Port-Host combination of the configured sensor here)
<IDENT-TOKEN>: prtg-is-great
The response will be sent to the HTTP Push Data Advanced sensor. Please create this sensor with the following settings:

Sensor Name: <NAME OF THE SERVICE>
Port: 5050 (Please use a different port, or Identification Token for every sensor!)
Identification Token: <YOUR-IDENT-TOKEN>
Other options: You can use the default settings for the other options.
The last step is to set a limit on the sensor's channel "$service status". To set this limit, activate the limits in the channel's settings and enter a "1" in the "Lower Error Limit (#)".

