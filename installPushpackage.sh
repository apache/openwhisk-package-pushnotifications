#!/bin/bash
#
# use the command line interface to install pushnotifications package.
# this script is in blue because it need blue whisk.properties.
#

: ${WHISK_SYSTEM_AUTH:?"WHISK_SYSTEM_AUTH must be set and non-empty"}
AUTH_KEY=$WHISK_SYSTEM_AUTH

SCRIPTDIR="$(cd $(dirname "$0")/ && pwd)"
parentdir="$(cd $(dirname "$SCRIPTDIR")/ && pwd)"
CATALOG_HOME=$parentdir
source "$CATALOG_HOME/util.sh"

# pushnotifications actions

echo Installing pushnotifications package.

createPackage pushnotifications \
    -a description "pushnotifications service" \
    -a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true}]' 

waitForAll

install "$CATALOG_HOME/pushnotifications/webhook.js" \
    pushnotifications/changes \
    -a feed true \
    -a description 'pushnotifications feed' \
    -a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true},{"name":"events", "required":true} ]'\
    -a sampleInput '{"appId":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "events":"onDeviceRegister"}' \
    -a sampleOutput '{"Result={"tagName": "tagName","eventType": "onDeviceRegister","applicationId": "xxx-xxx-xx"}"}'

install "$CATALOG_HOME/pushnotifications/sendMessage.js" \
    pushnotifications/sendMessage \
    -a description 'Send Push notification to device' \
    -a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true}, {"name":"text", "required":true}, {"name":"url", "required":false}, {"name":"deviceIds", "required":false}, {"name":"platforms", "required":false},{"name":"tagNames", "required":false},{"name":"gcmPayload", "required":false},{"name":"gcmSound", "required":false},{"name":"gcmCollapseKey", "required":false},{"name":"gcmDelayWhileIdle", "required":true}, {"name":"gcmPriority", "required":true}, {"name":"gcmTimeToLive", "required":true}, {"name":"apnsBadge", "required":false}, {"name":"apnsCategory", "required":false}, {"name":"apnsIosActionKey", "required":false},{"name":"apnsPayload", "required":false},{"name":"apnsType", "required":false},{"name":"apnsSound", "required":false}]' \
    -a sampleInput '{"appId":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "text":"hi there"}' \
    -a sampleOutput '{"Result={"pushResponse": {"messageId":"11111s","message":{"message":{"alert":"register for tag"}}}}"}'


waitForAll

echo pushnotifications package ERRORS = $ERRORS
exit $ERRORS
