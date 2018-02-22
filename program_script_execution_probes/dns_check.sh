#!/bin/bash
# 
# Script to check domain name expiration date.
#
# Set the website as an argument.

WEBSITE=$1
if [ -z "$WEBSITE" ] ; then
    echo "Please type the website you are up to check."

    exit 1
fi

# sed http(s):// , www. and any other staff after the domain zone like 'https://www.google.com/drive' -> 'google.com'
# grep for domain name and zone if there are subdomains like 'drive.google.com' -> 'google.com'
WEBSITE=$(echo $WEBSITE | sed -re 's/http(|s):\/\/(|www\.)//' | sed -re 's/\/.*//' | grep -oP '[A-Za-z0-9]*\.[A-Za-z0-9]*$')

# Find out the expiration date.
EXP_DATE=$(whois "$WEBSITE" | egrep -i 'Expiration|Expires on|Expiry date|paid-till' | head -1 | sed -e 's/^[^:]*://' -e 's/\./\//g' -e 's/T.*Z//g')
DATE=$(date --date="$EXP_DATE" '+%d %m %Y')
# Time arithmetics.
TIME1=$(date --date=$date +%s)
TIME2=$(date --date="$EXP_DATE" +%s)
DIFF=$(($TIME2-TIME1))
DAYS=$(($DIFF/86400))


echo "{\"Domain_name_will_be_expired_on\":\"$DATE\",\"Days_before_expiration\":\"$DAYS\"}" || exit 0