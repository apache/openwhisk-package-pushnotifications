#!/bin/bash
#
# use the command line interface to install standard actions deployed
# automatically
#
# To run this command
# ./installCatalog.sh  <AUTH> <APIHOST> <NAMESPACE> <WSK_CLI>
# AUTH, APIHOST and NAMESPACE are found in $HOME/.wskprops
# WSK_CLI="$OPENWHISK_HOME/bin/wsk"

set -e
set -x

if [ $# -eq 0 ]
then
echo "Usage: ./installCatalog.sh <authkey> <apihost> <namespace> <pathtowskcli>"
fi

AUTH="$1"
APIHOST="$2"
NAMESPACE="$3"
WSK_CLI="$4"

# If the auth key file exists, read the key in the file. Otherwise, take the
# first argument as the key itself.
if [ -f "$AUTH" ]; then
    AUTH=`cat $AUTH`
fi

PACKAGE_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export WSK_CONFIG_FILE= # override local property file to avoid namespace clashes

# pushnotifications actions

echo Installing pushnotifications package.

$WSK_CLI -i --apihost "$APIHOST"  package update --auth "$AUTH"  --shared yes "$NAMESPACE/pushnotifications" \
-a description "This package supports sending push notifications to your mobile device, using the IBM Bluemix Push Notifications service." \
-a parameters '[ {"name":"appGuid", "required":true, "bindTime":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"}]' \
-a prettyName "Push Notifications" \
-p bluemixServiceName 'imfpush'

$WSK_CLI -i --apihost "$APIHOST" action update --auth "$AUTH" "$NAMESPACE/pushnotifications/webhook" "$PACKAGE_HOME/feeds/webhook.js" \
-a feed true \
-a description 'pushnotifications feed' \
-a parameters '[ {"name":"appGuid", "required":true, "bindTime":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"},{"name":"events", "required":true, "description":"Name of the event user want to subscribe"} ]' \
-a sampleInput '{"appGuid":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "events":"onDeviceRegister"}' \
-a sampleOutput '{"tagName": "tagName","eventType": "onDeviceRegister","applicationId": "xxx-xxx-xx"}'


$WSK_CLI -i --apihost "$APIHOST" action update --auth "$AUTH" "$NAMESPACE/pushnotifications/sendMessage" "$PACKAGE_HOME/actions/sendMessage.js" \
-a description 'Send push notification to all application users or to a specific set of devices' \
-a parameters '[ {"name":"appGuid", "required":true, "bindTime":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"}, {"name":"text", "required":true, "description":"The notification message to be shown to the user"}, {"name":"url", "required":false, "description":"An optional URL that can be sent along with the alert"}, {"name":"deviceIds", "required":false, "description":"Array of device IDs"}, {"name":"platforms", "required":false, "description":"Array of device platform"},{"name":"tagNames", "required":false, "description":"Array of tag names"},{"name":"gcmPayload", "required":false, "description":"Additional payload"},{"name":"gcmSound", "required":false, "description":"Sound file name"},{"name":"gcmCollapseKey", "required":false, "description":"This parameter identifies a group of messages"},{"name":"gcmDelayWhileIdle", "required":false, "description":"Send message when device is active"}, {"name":"gcmPriority", "required":false, "description":"Sets the priority of the message"}, {"name":"gcmTimeToLive", "required":false, "description":"Time limit for message to be delievered"}, {"name":"gcmSync", "required":false, "description":"Device group messaging"}, {"name":"gcmVisibility", "required":false, "description":"private/public - Visibility of notification"}, {"name":"gcmStyleType", "required":false, "description":"Specifies the type of expandable notifications"}, {"name":"gcmStyleTitle", "required":false, "description":"Specifies the title of the notification"}, {"name":"gcmStyleUrl", "required":false, "description":"An URL from which the picture has to be obtained for the notification"}, {"name":"gcmStyleText", "required":false, "description":"The big text in bigtext_notification"}, {"name":"gcmStyleLines", "required":false, "description":"An array of strings for inbox_notification"}, {"name":"apnsBadge", "required":false, "description":"Value for Badge"}, {"name":"apnsCategory", "required":false, "description":"The category name"}, {"name":"apnsIosActionKey", "required":false, "description":"Title for the push notification action Key"},{"name":"apnsPayload", "required":false, "description":"Additional payload"},{"name":"apnsType", "required":false, "description":"Push notification type name"},{"name":"apnsSound", "required":false, "description":"APNS sound name"}, {"name":"fireFoxTitle", "required":false, "description":"Specifies the title to be set for the WebPush Notification"}, {"name":"fireFoxIconUrl", "required":false, "description":"The URL of the icon to be set for the WebPush Notification."}, {"name":"fireFoxTimeToLive", "required":false, "description":"This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline."}, {"name":"fireFoxPayload", "required":false, "description":"Custom JSON payload"}, {"name":"chromeTitle", "required":false, "description":"Specifies the title to be set for the WebPush Notification"}, {"name":"chromeIconUrl", "required":false, "description":"The URL of the icon to be set for the WebPush Notification"}, {"name":"chromeTimeToLive", "required":false, "description":"This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline."}, {"name":"chromePayload", "required":false, "description":"Custom JSON payload"}, {"name":"chromeAppExtTitle", "required":false, "description":"Specifies the title to be set for the WebPush Notification"}, {"name":"chromeAppExtCollapseKey", "required":false, "description":"This parameter identifies a group of messages"}, {"name":"chromeAppExtDelayWhileIdle", "required":false, "description":"When this parameter is set to true, it indicates that the message should not be sent until the device becomes active"}, {"name":"chromeAppExtIconUrl", "required":false, "description":"The URL of the icon to be set for the WebPush Notification"}, {"name":"chromeAppExtTimeToLive", "required":false, "description":"This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline"}, {"name":"chromeAppExtPayload", "required":false, "description":"Custom JSON payload"}]' \
-a sampleInput '{"appGuid":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "text":"hi there"}' \
-a sampleOutput '{"pushResponse": {"messageId":"11111s","message":{"message":{"alert":"register for tag"}}}}'
