#!/bin/bash

##############################
# This script is designed to download all the information from the EC2 instances to have a record 
# of the different instances we had at a given time.
# This script is meant to be run via a cron script but can be run stand alone also.
##############################
# Things you need to do:
# 1. Set the script log location
# 2. Set your environments
# 3. Set your regions.  You can use the filled in list to attempt to download all locations minus China and US government.  
#    It is helpful to download all regions as you never know when a person might stand up a server in a region
#    you don't normally use.
##############################
# This script relies on you setting up named profiles.  Please refer to the following on setting up named profiles.
# You script also relies on the default output format being JSON.
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
##############################


# Log location | The path needs to end with the /
scriptlogs="/path/to/your/log/folder/"

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

#cleaning up old files from previous runs
echo "Cleaning up old file"

rmfile="ec2list_*.json"
removal=$scriptlogs$rmfile
rm -f $removal
echo "Clean up done"

# Downloading the EC2 instance information
echo "Starting Downloads"

for i in "${region[@]}"
do
    echo ""
    echo "Working on Region $i"
       for z in "${environment[@]}"
       do
	   filename="ec2list_"$z"_"$i".json"
    	   echo "Downloading $z in $i in to $scriptlogs$filename"
           aws ec2 describe-instances --profile $z --region $i > $scriptlogs$filename
       done
    
done

# All Done
echo ""
echo "##############################"
echo "## All finished with script ##"
echo "##############################"
