#!/bin/bash

# An example to cteate new user with credentials:
# - login - $1 - e.g. user email-address;
# - password - $2;
# and permissions limited to:
# - manage objects - [\"manage-objects\"];
# - manage monitoring settings - [\"manage-service-properties\"];
# - inside his/her own workspace (object) - {\"objectPermissions\":{\"include\":[\"$workspaceId\"],\"exclude\":[]}}.
# See below arguments' description.

# Global variables - START
# You can modify and use this section to pass these arguments to the script
serverURL="https://saas.saymon.info" # SAYMON server URL
user_login="$1" # new user login
user_password="$2" # new user password
parent_id=5a86559355f16c6d948c874c # The ID of the object, where we are going to create the workspace (object) for the new user
adminAuthToken=87cdda06-a951-42d6-b651-db51fb870674 # existing admin-user auth token to use in REST-API methods
# To get admin auth token:
# login to SAYMON webui
# open "Configuration" window
# choose your existing admin-user
# on "General" tab generate "Authorization link" if the field is empty
# copy auth-token
# paste it above
# Global variables - END

# Creates new workspace (USER object) for user
apiMethod="node/api/objects" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$adminAuthToken" # Generates URL for the query
workspaceName="$user_login" # The name of our USER object (matches user login)
class_id=32 # The CLASS ID of our object; 32 is a USER
myJSON="{\"name\":\"$workspaceName\",\"parent_id\": \"$parent_id\",\"class_id\": \"$class_id\"}" # Generates data for the query
# echo; echo myJSON QUERY - $myJSON; echo # result for the previous command for some kind of debugging
workspace=$(curl -H "Content-Type: application/json" -X POST -d "$myJSON" $queryURL) # Query to create workspace
# echo; echo workspace QUERY RESULT - $workspace; echo # result for the previous command for some kind of debugging
workspaceId=$(echo $workspace | grep -Eo '"id":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo; echo workspaceId - $workspaceId; echo # result for the previous command for some kind of debugging

# Creates new user with limited permissions and access only to the previously created workspace
apiMethod="node/api/users" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$adminAuthToken" # Generates URL for the query
myJSON="{\"login\": \"$user_login\", \"password\": \"$user_password\", \"permissions\": [\"manage-objects\",\"manage-service-properties\"], \"objectPermissions\":{\"include\":[\"$workspaceId\"],\"exclude\":[]}}" # Generates data for the query
# echo; echo myJSON QUERY - $myJSON; echo # result for the previous command for some kind of debugging
newUser=$(curl -H "Content-Type: application/json" -X POST -d "$myJSON" $queryURL) # Query to create user
# echo; echo newUser QUERY RESULT - $newUser; echo # result for the previous command for some kind of debugging - server json answer

# Gets new user info
userLogin=$(echo $newUser | grep -Eo '"login":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo newUser LOGIN - $userLogin # result for the previous command for some kind of debugging
userId=$(echo $newUser | grep -Eo '"id":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo newUser ID - $userId # result for the previous command for some kind of debugging
userAuthToken=$(echo $newUser | grep -Eo '"authenticationToken":.*?[^\\]"' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X
# echo newUser AUTH TOKEN - $userAuthToken # result for the previous command for some kind of debugging

# Creates auth-token for new user
apiMethod="node/api/users/$userId/auth-token" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$adminAuthToken" # Generates URL for the query
userAuthToken=$(curl -H "Content-Type: application/json" -X POST $queryURL | sed 's/"//g') # Query to create auth-token
# echo; echo newUser AUTH TOKEN - $userAuthToken; echo # result for the previous command for some kind of debugging - server json answer