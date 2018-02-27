#!/bin/bash

# An example to create new admin-user with all permissions.
# See below arguments' description.

# Global variables - START
# You can modify and use this section to pass these arguments to the script
serverURL="https://saas.saymon.info" # SAYMON server URL
user_login="$1" # new admin-user login
user_password="$2" # new admin-user password
userAuthToken=87cdda06-a951-42d6-b651-db51fb870674 # existing admin-user auth token to use in REST-API methods
# To get user auth token:
# login to SAYMON webui
# open "Configuration" window
# choose your existing admin-user
# on "General" tab generate "Authorization link" if the field is empty
# copy auth-token
# paste it above
# Global variables - END

# Creates new admin-user
apiMethod="node/api/users" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$userAuthToken" # Generates URL for the query
myJSON="{\"login\": \"$user_login\", \"password\": \"$user_password\", \"permissions\": [\"manage-objects\", \"manage-links\", \"manage-flows\", \"manage-documents\", \"manage-properties\", \"manage-classes\", \"execute-operations\", \"run-bulks\", \"run-discovery\", \"manage-configuration\", \"manage-service-properties\", \"upload-agent-updates\", \"manage-users\", \"manage-event-log\", \"manage-history\"]}" # Generates data for the query
# echo; echo myJSON QUERY - $myJSON; echo # result for the previous command for some kind of debugging
newUser=$(curl -H "Content-Type: application/json" -X POST -d "$myJSON" $queryURL)
# echo; echo newUser QUERY RESULT - $newUser; echo # result for the previous command for some kind of debugging - server json answer