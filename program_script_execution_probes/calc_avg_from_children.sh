#/bin/bash
# Iterates children objects of the given object ($1)
# and calculates average for the responseTimeMs metric if presents.

# Global variables - START
# You can modify and use this section to pass these arguments to the script
objectParentID=$(echo $1) # The ID of the given parent object, which subobjects we are going to iterate
serverURL="https://saas.saymon.info" # SAYMON server URL
userAuthToken=87cdda06-a951-42d6-b651-db51fb870674 # user auth token to use in REST-API methods - use read-only user for the security reasons
# To get user auth token:
# login to SAYMON webui
# open "Configuration" window
# create new user
# on "Permissions" tab choose "Deny all" option
# on "General" tab generate "Authorization link"
# copy auth-token
# paste it above
# Global variables - END

# Get a list of subobjects - START
apiMethod="node/api/objects/$objectParentID" # SAYMON REST API method to use in a query
queryURL="$serverURL/$apiMethod?api-token=$userAuthToken" # Generates URL for the query
subobjectsListRaw=$(curl --silent -H "Content-Type: application/json" -X GET $queryURL) # Performs the query
# echo; echo subobjectsListRaw QUERY RESULT - $subobjectsListRaw; echo # result for the previous command for some kind of debugging - server json answer
subobjectsList=$(echo $subobjectsListRaw | grep -Po '"child_ids":.*?[^\\]\]' | sed -re 's/"|\[|\]//g' | awk -F ':' {'print $2'} | sed 's/,/ /g' ) # use -Po for grep in Linux / -Eo for grep in Mac OS X / parses server json-reply and gets of subobjects ids as a sting separated with white-spaces
# echo; echo SUBOBJECTS IDs - $subobjectsList; echo # result for the previous command for some kind of debugging
# Get a list of subobjects - END

# Iteration - START
sum=0 # sum of responseTimeMs metric values
div=0 # number of responseTimeMs metric values

for i in $subobjectsList # for each subobject: get stat, find value by metric name, check if metric exists or >= 0, summ it to sum=0, +1 to div=0
	do
		apiMethod="node/api/objects/$i/stat" # SAYMON REST API method to use in a query
		queryURL="$serverURL/$apiMethod?api-token=$userAuthToken" # Generates URL for the query
		subobjectStatRaw=$(curl --silent -H "Content-Type: application/json" -X GET $queryURL) # Performs the query
#		 echo; echo subobjectStatRaw QUERY RESULT - $subobjectStatRaw; echo # result for the previous command for some kind of debugging - server json answer
		subobjectStat=$(echo $subobjectStatRaw | grep -Po '"responseTimeMs":.*[0-9]' | sed 's/"//g' | awk -F ':' {'print $2'} ) # use -Po for grep in Linux / -Eo for grep in Mac OS X - gets responseTimeMs metric value
#		 echo; echo subobjectStat - $subobjectStat; echo # result for the previous command for some kind of debugging
		if [ "$subobjectStat" -eq "$subobjectStat" ] 2>/dev/null # if responseTimeMs metric exists and its value is an integer
		then # if true
			sum=$(expr $sum + $subobjectStat) # sums values
			div=$(expr $div + 1) # enlarges number of summed values
#		else # if false - does nothing
		fi
	done
# Iteration - END

# Calculates average responseTimeMs as sum/div
avg=$(expr $sum / $div)

# Return desired average value of responseTimeMs metrics
echo "{\"responseTimeMs\": $avg}"
