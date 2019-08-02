#!/bin/bash

##############################
# This script is designed to download the dns information from your AWS instances for 
# Load Balancers.  It will then get the the current ip address(es) for the dns name.
# This script is meant to be run via a cron script but can be run stand alone also.
##############################
# Things you need to do:
# 1. Set the script log location
# 2. Set the temp log location
# 3. Set your environments (Named Profiles)
# 4. Set your regions.  You can use the filled in list to attempt to download all 
#    locations minus China and US government.  It is helpful to download all regions as 
#    you never know when a person might stand up a server in a region you don't 
#    normally use.
##############################
# This script relies on you setting up named profiles.  Please refer to the following on 
# setting up named profiles.
# You script also relies on the default output format being JSON.
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
##############################

#Get EPOCH timestamp as variable
timestamp=$(date '+%s')

# Declare variables
# Log location | The path needs to end with the /
scriptlogs="/path/to/your/log/folder/"

# Temp Location | The path needs to end with the /
templogs="/path/to/your/temp/folder/"

# Files
lb2ip="lb2ip.csv"
lblist="lblist.txt"
tempfile="temp.txt"

# File Paths
lb2ippath=$scriptlogs$lb2ip
lblistpath=$templogs$lblist
tempfilepath=$templogs$tempfile

# Example Environments
# In this example the account numbers are setup as the named instance.
# Prod = 123456789012
# Stage = 234567890123
# Test = 345678901234
# Dev = 456789012345

environment=(
123456789012
234567890123
345678901234
456789012345
)

#List of Regions
#us-east-2
#us-east-1
#us-west-1
#us-west-2
#ap-south-1
#ap-northeast-3
#ap-northeast-2
#ap-southeast-1
#ap-southeast-2
#ap-northeast-1
#ca-central-1
#cn-north-1
#cn-northwest-1
#eu-central-1
#eu-west-1
#eu-west-2
#eu-west-3
#eu-north-1
#sa-east-1
#us-gov-east-1
#us-gov-west-1

# The US and China regions are not in the array by default

region=( 
us-east-2
us-east-1
us-west-1
us-west-2
ap-south-1
ap-northeast-3
ap-northeast-2
ap-southeast-1
ap-southeast-2
ap-northeast-1
ca-central-1
eu-central-1
eu-west-1
eu-west-2
eu-west-3
eu-north-1
sa-east-1
)

# Making sure we cleaned up old files from previous runs
echo "Cleaning up old file"
echo "Removing $lb2ippath"
rm -f $lb2ippath

echo "Removing $lblistpath"
rm -f $lblistpath
 
echo "Removing $tempfilepath"
rm -f $tempfilepath

echo "Clean up done"

#Building the header of the CSV file
printf "timestamp,environment,dnsname,ipaddr"'%s\n' > $lb2ippath

for i in "${region[@]}"
	do
		echo ""
		echo "Working on Region $i"
		
		for z in "${environment[@]}"
			do
				filename="lblist_"$z"_"$i".txt"
				
				aws elb describe-load-balancers --profile $z --region $i | grep "DNSName" | cut -d ':' -f2 | cut -d '"' -f2 > $lblistpath
				aws elbv2 describe-load-balancers --profile $z --region $i | grep "DNSName" | cut -d ':' -f2 |cut -d '"' -f2 >> $lblistpath
           
					while read line;
						do
						
							dig @8.8.8.8 +short $line > $tempfilepath;
							IFS=$'\n' read -d '' -r -a lines < $tempfilepath;
							printf "$timestamp,$z,$line,"'%s\n' "${lines[@]}" >> $lb2ippath;

						done < $lblistpath
			done
    
	done
