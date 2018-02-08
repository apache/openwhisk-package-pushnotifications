#!/bin/bash
#
# use the command line interface to install standard actions deployed
# automatically
#
# To run this command
# ./installCatalog.sh  <AUTH> <APIHOST> <WSK_CLI>
# AUTH and APIHOST are found in $HOME/.wskprops
# WSK_CLI="$OPENWHISK_HOME/bin/wsk"

set -e
set -x

if [ $# -eq 0 ]
then
echo "Usage: ./installCatalog.sh <authkey> <apihost> <pathtowskcli>"
fi

AUTH="$1"
APIHOST="$2"
WSK_CLI="$3"

# If the auth key file exists, read the key in the file. Otherwise, take the
# first argument as the key itself.
if [ -f "$AUTH" ]; then
    AUTH=`cat $AUTH`
fi

PACKAGE_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export WSK_CONFIG_FILE= # override local property file to avoid namespace clashes

# pushnotifications actions

echo Installing pushnotifications package.

$WSK_CLI -i --apihost "$APIHOST"  package update --auth "$AUTH"  --shared yes "pushnotifications" \
-a description "This package supports sending push notifications to your mobile device, using the IBM Bluemix Push Notifications service." \
-a parameters '[ {"name":"appGuid", "required":true, "bindTime":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"}, {"name":"admin_url", "required":false, "bindTime":true}]' \
-a prettyName "Push Notifications" \
-p bluemixServiceName 'imfpush'

$WSK_CLI -i --apihost "$APIHOST" action update --kind nodejs:6 --auth "$AUTH" "pushnotifications/webhook" "$PACKAGE_HOME/feeds/webhook.js" \
-a feed true \
-a description 'pushnotifications feed' \
-a parameters '[ {"name":"appGuid", "required":true, "bindTime":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"},{"name":"events", "required":true, "description":"Name of the event user want to subscribe"} ]' \
-a sampleInput '{"appGuid":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "events":"onDeviceRegister"}' \
-a sampleOutput '{"tagName": "tagName","eventType": "onDeviceRegister","applicationId": "xxx-xxx-xx"}'


$WSK_CLI -i --apihost "$APIHOST" action update --kind nodejs:6 --auth "$AUTH" "pushnotifications/sendMessage" "$PACKAGE_HOME/actions/sendMessage.js" \
-a description 'Send push notification to all application users or to a specific set of devices' \
-a parameters '[ {"name":"appGuid", "required":true, "bindTime":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"}, {"name":"text", "required":true, "description":"The notification message to be shown to the user"}, {"name":"url", "required":false, "description":"An optional URL that can be sent along with the alert"}, {"name":"apiHost", "required":false, "description":"API host"}, {"name":"deviceIds", "required":false, "description":"Array of device IDs"}, {"name":"platforms", "required":false, "description":"Array of device platform"},{"name":"userIds", "required":false, "description":"Array of UserIds"},{"name":"tagNames", "required":false, "description":"Array of tag names"},{"name":"gcmCollapseKey", "required":false, "description":"This parameter identifies a group of messages"},{"name":"gcmCategory", "required":false, "description":"The category identifier to be used for the interactive push notifications"},{"name":"gcmIcon", "required":false, "description":"Specify the name of the icon to be displayed for the notification"},{"name":"gcmDelayWhileIdle", "required":false, "description":"Send message when device is active"}, {"name":"gcmSync", "required":false, "description":"Device group messaging"}, {"name":"gcmVisibility", "required":false, "description":"private/public - Visibility of notification"},{"name":"gcmPayload", "required":false, "description":"Additional payload"}, {"name":"gcmPriority", "required":false, "description":"Sets the priority of the message"},{"name":"gcmSound", "required":false, "description":"Sound file name"}, {"name":"gcmTimeToLive", "required":false, "description":"Time limit for message to be delivered"}, {"name":"gcmStyleType", "required":false, "description":"Specifies the type of expandable notifications"}, {"name":"gcmStyleTitle", "required":false, "description":"Specifies the title of the notification"}, {"name":"gcmStyleUrl", "required":false, "description":"An URL from which the picture has to be obtained for the notification"}, {"name":"gcmStyleText", "required":false, "description":"The big text in bigtext_notification"}, {"name":"gcmStyleLines", "required":false, "description":"An array of strings for inbox_notification"},{"name":"gcmLightsLedArgb", "required":false, "description":"The color of the led. The hardware will do its best approximation"},{"name":"gcmLightsLedOnMs", "required":false, "description":"The number of milliseconds for the LED to be on while it is flashing. The hardware will do its best approximation"},{"name":"gcmLightsLedOffMs", "required":false, "description":"The number of milliseconds for the LED to be off while it iss flashing. The hardware will do its best approximation"},{"name":"apnsBadge", "required":false, "description":"Value for Badge"}, {"name":"apnsCategory", "required":false, "description":"The category name"}, {"name":"apnsIosActionKey", "required":false, "description":"Title for the push notification action Key"},{"name":"apnsPayload", "required":false, "description":"Additional payload"},{"name":"apnsType", "required":false, "description":"Push notification type name"},{"name":"apnsSound", "required":false, "description":"APNS sound name"}, {"name":"apnsTitleLocKey", "required":false, "description":"The key to a title string in the Localizable.strings file for the current localization"},{"name":"apnsLocKey", "required":false, "description":"A key to an alert-message string in a Localizable.strings file for the current localization"},{"name":"apnsLaunchImage", "required":false, "description":"The filename of an image file in the app bundle, with or without the filename extension"},{"name":"apnsTitleLocArgs", "required":false, "description":"Variable string values to appear in place of the format specifiers in title-loc-key"},{"name":"apnsLocArgs", "required":false, "description":"Variable string values to appear in place of the format specifiers in locKey"},{"name":"apnstitle", "required":false, "description":"The title of Rich Push notifications"},{"name":"apnsSubtitle", "required":false, "description":"The subtitle of the Rich Notifications"},{"name":"apnsAttachmentUrl", "required":false, "description":"The link to the iOS notifications media"},{"name":"fireFoxTitle", "required":false, "description":"Specifies the title to be set for the WebPush Notification"}, {"name":"fireFoxIconUrl", "required":false, "description":"The URL of the icon to be set for the WebPush Notification."}, {"name":"fireFoxTimeToLive", "required":false, "description":"This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline."}, {"name":"fireFoxPayload", "required":false, "description":"Custom JSON payload"}, {"name":"chromeTitle", "required":false, "description":"Specifies the title to be set for the WebPush Notification"}, {"name":"chromeIconUrl", "required":false, "description":"The URL of the icon to be set for the WebPush Notification"}, {"name":"chromeTimeToLive", "required":false, "description":"This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline."}, {"name":"chromePayload", "required":false, "description":"Custom JSON payload"},{"name":"safariTitle", "required":false, "description":"Specifies the title to be set for the Safari Push Notifications"},{"name":"safariUrlArgs", "required":false, "description":"The URL arguments that need to be used with this notification. This has to provided in the form of a JSON Array"},{"name":"safariAction", "required":false, "description":"The label of the action button"},{"name":"chromeAppExtTitle", "required":false, "description":"Specifies the title to be set for the WebPush Notification"}, {"name":"chromeAppExtCollapseKey", "required":false, "description":"This parameter identifies a group of messages"},{"name":"chromeAppExtDelayWhileIdle", "required":false, "description":"When this parameter is set to true, it indicates that the message should not be sent until the device becomes active"}, {"name":"chromeAppExtIconUrl", "required":false, "description":"The URL of the icon to be set for the WebPush Notification"}, {"name":"chromeAppExtTimeToLive", "required":false, "description":"This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline"}, {"name":"chromeAppExtPayload", "required":false, "description":"Custom JSON payload"}]' \
-a sampleInput '{"appGuid":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "text":"hi there"}' \
-a sampleOutput '{"pushResponse": {"messageId":"11111s","message":{"message":{"alert":"register for tag"}}}}'
