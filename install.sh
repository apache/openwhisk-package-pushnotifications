#!/bin/bash
#
# use the command line interface to install standard actions deployed
# automatically
#
# To run this command
# ./install.sh <apihost> <authkey> <pathtowskcli>
# ./install.sh APIHOST="$EDGE_HOST" AUTH="$AUTH_KEY" WSK_CLI="$OPENWHISK_HOME/bin/wsk"
# API_HOST and AUTH_KEY are found in $HOME/.wskprops

set -e
set -x

if [ $# -eq 0 ]
then
echo "Usage: ./install.sh <apihost> <authkey> <pathtowskcli>"
fi

APIHOST="$1"
AUTH="$2"
WSK_CLI="$3"

# pushnotifications actions

echo Installing pushnotifications package.

$WSK_CLI --apihost "$APIHOST"  package update --auth "$AUTH"  --shared yes pushnotifications \
-a description "pushnotifications service" \
-a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true}]'

$WSK_CLI --apihost "$APIHOST" action update --auth "$AUTH" --shared yes pushnotifications/webhook "webhook.js" \
-a feed true \
-a description 'pushnotifications feed' \
-a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true},{"name":"events", "required":true} ]' \
-a sampleInput '{"appId":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "events":"onDeviceRegister"}' \
-a sampleOutput '{"Result={"tagName": "tagName","eventType": "onDeviceRegister","applicationId": "xxx-xxx-xx"}"}'


$WSK_CLI --apihost "$APIHOST" action update --auth "$AUTH" --shared yes pushnotifications/sendMessage "sendMessage.js" \
-a description 'Send Push notification to device' \
-a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true}, {"name":"text", "required":true}, {"name":"url", "required":false}, {"name":"deviceIds", "required":false}, {"name":"platforms", "required":false},{"name":"tagNames", "required":false},{"name":"gcmPayload", "required":false},{"name":"gcmSound", "required":false},{"name":"gcmCollapseKey", "required":false},{"name":"gcmDelayWhileIdle", "required":true}, {"name":"gcmPriority", "required":true}, {"name":"gcmTimeToLive", "required":true}, {"name":"apnsBadge", "required":false}, {"name":"apnsCategory", "required":false}, {"name":"apnsIosActionKey", "required":false},{"name":"apnsPayload", "required":false},{"name":"apnsType", "required":false},{"name":"apnsSound", "required":false}]' \
-a sampleInput '{"appId":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "text":"hi there"}' \
-a sampleOutput '{"Result={"pushResponse": {"messageId":"11111s","message":{"message":{"alert":"register for tag"}}}}"}'
