#!/bin/bash

# An example to cteate HW object with child HTTP-REQUEST-probe subobject.

# Global variables - START
# You can modify and use this section to pass these arguments to the script
serverURL="https://saas.saymon.info" # SAYMON server URL
parent_id=5a95706da958a936ddeee13d # The ID of the object, where we are going to experiment and create our objects
agent_id=5a95706da958a937dcdef34a # The ID of the SAYMON Agent to perform SCRIPT-EXECUTION-probe
url=https://saymon.info # The url to request
userAuthToken=87cdda06-a951-42d6-b651-db51fb870674 # existing user auth token to use in REST-API methods
# To get user auth token:
# login to SAYMON webui
# open "Configuration" window
# choose your existing user
# on "General" tab generate "Authorization link" if the field is empty
# copy auth-token
# paste it above
# Global variables - END

# Gets user id, token and login
apiMethod="node/api/users/current" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$userAuthToken" # Generates URL for the query
user=$(curl -H "Content-Type: application/json" -X GET $queryURL) # Query to get user info
# echo; echo USER QUERY RESULT - $user; echo # result for the previous command for some kind of debugging
userLogin=$(echo $user | grep -Eo '"login":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo User LOGIN - $userLogin # result for the previous command for some kind of debugging
userId=$(echo $user | grep -Eo '"id":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo User ID - $userId # result for the previous command for some kind of debugging
userAuthToken=$(echo $user | grep -Eo '"authenticationToken":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo User AUTH TOKEN - $userAuthToken # result for the previous command for some kind of debugging

# Creates new HARDWARE object
apiMethod="node/api/objects" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$userAuthToken" # Generates URL for the query
objectGroupName="HARDWARE - $userLogin" # The NAME of our HARDWARE object with user login postfix
class_id=20 # The CLASS ID of our object; 20 is a HARDWARE
myJSON="{\"name\":\"$objectGroupName\",\"parent_id\": \"$parent_id\",\"class_id\": \"$class_id\"}" # Generates data for the query
# echo; echo myJSON QUERY - $myJSON; echo # result for the previous command for some kind of debugging
objectGroup=$(curl -H "Content-Type: application/json" -X POST -d "$myJSON" $queryURL) # Query to create HARDWARE object
# echo; echo objectGroup QUERY RESULT - $objectGroup; echo # result for the previous command for some kind of debugging
objectGroupId=$(echo $objectGroup | grep -Eo '],"id":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo; echo objectGroupID CREATED OBJECT ID - $objectGroupId; echo # result for the previous command for some kind of debugging

	# Creates INFO subobject (child for previously created HARDWARE object)
	# Requested URL - https://saymon.info - $url
	# Weight - 0.6 (see \"weight\": 0.6 in myJSON below)
	apiMethod="node/api/objects" # SAYMON REST API method to use in a query
	queryURL="$serverURL/$apiMethod?api-token=$userAuthToken" # Generates URL for the query
	objectName="INFO - HTTP-REQUEST-probe" # The NAME of our INFO object
	class_id=24 # The CLASS ID of our object; 24 is a INFO
	myJSON="{\"name\":\"$objectName\",\"parent_id\": \"$objectGroupId\",\"class_id\": \"$class_id\", \"weight\": 0.6, \"properties\":[{\"name\": \"AgentId\",\"value\": \"$agent_id\",\"type_id\": \"8\"},{\"name\": \"TaskType\",\"value\": \"httpRequest\",\"type_id\": \"8\"},{\"name\": \"HttpRequestMethod\",\"value\": \"GET\",\"type_id\": \"8\"},{\"name\": \"HttpRequestUrl\",\"value\": \"$url\",\"type_id\": \"8\"},{\"name\": \"HttpRequestHeaders\",\"value\": \"{\\\"User-Agent\\\":\\\"SAYMON Agent (saymon.info)\\\"}\",\"type_id\": \"8\"},{\"name\": \"HttpRequestIncludeResponseBody\",\"value\": \"true\",\"type_id\": \"8\"},{\"name\": \"HttpRequestForceParse\",\"value\": \"AUTO\",\"type_id\": \"8\"},{\"name\":\"TaskPeriodUnit\",\"value\": \"seconds\",\"type_id\": \"8\"},{\"name\": \"TaskPeriodValue\",\"value\": \"600\",\"type_id\": \"8\"}]}" # Generates data for the query
	# echo; echo myJSON QUERY - $myJSON; echo # result for the previous command for some kind of debugging
	subObject=$(curl -H "Content-Type: application/json" -X POST -d "$myJSON" $queryURL) # Query to create INFO object
	# echo; echo subObject QUERY RESULT - $subObject; echo # result for the previous command for some kind of debugging
	subObjectId=$(echo $subObject | grep -Eo '],"id":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
	# echo; echo subObjectId CREATED SUBOBJECT ID - $subObjectId; echo # result for the previous command for some kind of debugging