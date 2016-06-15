#/
# Copyright 2015-2016 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#/
#!/bin/bash
#
# use the command line interface to install pushnotifications package.
# this script is in blue because it need blue whisk.properties.
#

#: ${WHISK_SYSTEM_AUTH:?"WHISK_SYSTEM_AUTH must be set and non-empty"}
AUTH_KEY=`cat ../../../credentials/auth.whisk.system`

SCRIPTDIR="$(dirname "$0")"
CATALOG_HOME='../'
source "$CATALOG_HOME/util.sh"

# pushnotifications actions

echo Installing pushnotifications package.

createPackage pushnotifications \
-a description "pushnotifications service" \
-a parameters '[ {"name":"appId", "required":true}, {"name":"appSecret", "required":true}]'

waitForAll

install "$CATALOG_HOME/pushnotifications/webhook.js" \
pushnotifications/webhook \
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