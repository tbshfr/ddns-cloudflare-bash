#!/bin/bash

#: Title              : dyndns.sh
#: Date               : 30.03.2023
#: Author             : tbshfr
#: Version            : 1
#: Description        : This script updates an A record to point to your dynamic IP.
#                       It must be used with Cloudflare.
#                       It can send you a notification through a Telegram Bot.
#
#--------------------------------------------------------------------------------------------

# Cloudflare Variables
API_TOKEN="insert API Token"
ZONE_ID="insert zone id"
A_RECORD="home.example.com"
PROXIED="false" # true/false
TTL="300" # in seconds

# Telegram Notifications
USE_TELEGRAM="yes" # yes/no
BOT_API_TOKEN="insert your Bot API Token"
TG_CHAT_ID="insert the your Chat ID"

# Folder for ip and history files
FOLDER="/home/user/dyndns"
TIMEZONE="Europe/Berlin"

#---------------------------------------------------------------------------------------------

# create IP file
touch -a $FOLDER/ip.txt
IP_FILE="$FOLDER/ip.txt"

# create history file
touch -a $FOLDER/history.txt
HISTORY_FILE="$FOLDER/history.txt"

# define Timestamp for history file
timestamp() {
      TZ=$TIMEZONE date "+%d %b %Y %T %Z"
}

# get the last recorded IP
OLD_IP=$(cat $IP_FILE)

# get the current IP
PUBLIC_IP=$(curl -m 20 -s -4 icanhazip.com) || exit 1

# check if the IP changed
if [ "$PUBLIC_IP" = "$OLD_IP" ]; then
    echo "IP hasn't changed, nothing to do"
    exit 0
fi

# if it has changed, write it to ip.txt
echo $PUBLIC_IP > $IP_FILE

# get the record ID
RECORD_ID_FULL=$(curl -m 20 -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$A_RECORD" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json")

RECORD_ID=$(echo ${RECORD_ID_FULL} | grep -o '"id":"[^"]*' | cut -d'"' -f4)

# prepare the new record
NEW_RECORD=$(cat <<EOF
{ "type": "A",
  "name": "$A_RECORD",
  "content": "$PUBLIC_IP",
  "ttl": $TTL,
  "proxied": $PROXIED }
EOF
)

# change the IP Address on Cloudflare using API v4
UPDATE_RECORD=$(curl -m 20 -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
                     -H "Authorization: Bearer $API_TOKEN" \
                     -H "Content-Type: application/json" \
                     --data "$NEW_RECORD")

RESULT=$(if [[ ${UPDATE_RECORD} == *"\"success\":true"* ]]; then
             echo "Updated $A_RECORD to $PUBLIC_IP"
         else
             echo "Error, could not update $A_RECORD"
         fi)

echo "$(timestamp): $RESULT" | tee -a $HISTORY_FILE

# Telegram notifications
if [ ${USE_TELEGRAM} == "yes" ]; then
    curl -m 20 -s -X GET "https://api.telegram.org/bot${BOT_API_TOKEN}/sendMessage?chat_id=${TG_CHAT_ID}" --data-urlencode "text=dyndns: $RESULT" > /dev/null 2>&1
else
    :
fi

# exit status
if [[ ${RESULT} == "Error, could not update $A_RECORD" ]]; then
    echo "Please check whether variables are filled out correctly"
    rm $IP_FILE
    exit 1
else
    echo "Success!"
    exit 0
fi
