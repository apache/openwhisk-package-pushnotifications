/*
* Copyright 2015-2016 IBM Corporation
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/**

 *  Action to Send Push Notification using IBM Push Notifications service
 *
 *  @param {string} appId - appId to create webhook
 *  @param {string} appSecret - appSecret of the application
 *  @param {string} url - An optional URL that can be sent along with the alert. Eg : -p url "https:\\www.w3.ibm.com".
 *  @param {object} text - The notification message to be shown to the user. Eg: -p text "Hi ,OpenWhisk send a notification"
 *  @param {string} deviceIds - Send notification to the list of specified devices. Eg: -p deviceIds "["deviceID1"]"
 *  @param {object} platforms - Send notification to the devices of the specified platforms. 'A' for apple (iOS) devices and 'G' for google (Android) devices. Eg: -p platforms ["A"]
 *  @param {string} tagNames - Send notification to the devices that have subscribed to any of these tags. Eg -p tagNames "["tag1"]"
 *  @param {string} gcmPayload - Custom JSON payload that will be sent as part of the notification message. Eg: -p gcmPayload "{"hi":"hello"}".
 *  @param {string} gcmSound - The sound file (on device) that will be attempted to play when the notification arrives on the device.
 *  @param {string} gcmCollapseKey - This parameter identifies a group of messages.
 *  @param {string} gcmDelayWhileIdle - When this parameter is set to true, it indicates that the message should not be sent until the device becomes active.
 *  @param {string} gcmPriority - Sets the priority of the message.
 *  @param {string} gcmTimeToLive - This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline.
 *  @param {string} apnsBadge - The number to display as the badge of the application icon.
 *  @param {string} apnsCategory -  The category identifier to be used for the interactive push notifications.
 *  @param {string} apnsIosActionKey - The title for the Action key.
 *  @param {string} apnsPayload - Custom JSON payload that will be sent as part of the notification message.
 *  @param {string} apnsType - ['DEFAULT', 'MIXED', 'SILENT'].
 *  @param {string} apnsSound - The name of the sound file in the application bundle. The sound of this file is played as an alert.
 *  @return {object} whisk async.
*/
module.paths.push('/usr/lib/node_modules');
var https = require('https');

function main(params) {
    if (validateParams(params)) {

        var appId = params.appId;
        var appSecret = params.appSecret;

        // message section settings
        var messageUrl = params.url;
        var messageText = params.text;

        // target section settings -- each param should be an array of string
        var targetDeviceIds = params.deviceIds;
        var targetPlatforms = params.platforms;
        var targetTagNames = params.tagNames;

        // apns settings
        var apnsBadge = params.apnsBadge; // should be an int
        var apnsCategory = params.apnsCategory;
        var apnsActionKeyTitle = params.apnsIosActionKey;
        var apnsSound = params.apnsSound;
        var apnsPayload = params.apnsPayload;
        var apnsType = params.apnsType;

        // gcm settings
        var gcmCollapseKey = params.gcmCollapseKey;
        var gcmDelayWhileIdle = params.gcmDelayWhileIdle;
        var gcmPayload = params.gcmPayload;
        var gcmPriority = params.gcmPriority;
        var gcmSound = params.gcmSound;
        var timeToLive = params.gcmTimeToLive;

        var sendMessage = {};

        // create message section
        var message = {};
        if (messageText) {
            message.alert = messageText;
        }
        if (messageUrl) {
            message.url = messageUrl;
        }

        if (isEmpty(message)) {
            whisk.error("No message to send");
            return {message: "IBM Push Notifications action: no message body text or url"};
        } else {
            sendMessage.message = message;
        }

        // create target section
        var target = {};
        if (targetDeviceIds) {
            target.deviceIds = targetDeviceIds;
        }
        if (targetPlatforms) {
            target.platforms = targetPlatforms;
        }
        if (targetTagNames) {
            target.tagNames = targetTagNames;
        }

        if (isEmpty(target)) {
            console.log("No target set, broadcasting message to all registered devices");
        } else {
            sendMessage.target = target;
        }

        // create apns settings section
        var apns = {};
        if (apnsBadge) {
            apns.badge = apnsBadge;
        }
        if (apnsCategory) {
            apns.category = apnsCategory;
        }
        if (apnsActionKeyTitle) {
            apns.iosActionKey = apnsActionKeyTitle;
        }
        if (apnsSound) {
            apns.sound = apnsSound;
        }
        if (apnsType) {
            apns.type = apnsType;
        }
        if (apnsPayload) {
            apns.payload = apnsPayload;
        }

        if (!isEmpty(apns)) {
            sendMessage.settings = {};
            sendMessage.settings.apns = apns;
        }

        // create gcm settings section
        var gcm = {};
        if (gcmCollapseKey) {
            gcm.collapseKey = gcmCollapseKey;
        }
        if (gcmDelayWhileIdle) {
            gcm.delayWhileIdle = gcmDelayWhileIdle;
        }
        if (gcmPayload) {
            gcm.payload = gcmPayload;
        }
        if (gcmPriority) {
            gcm.priority = gcmPriority;
        }
        if (gcmSound) {
            gcm.sound = gcmSound;
        }
        if (timeToLive) {
            gcm.timeToLive = timeToLive;
        }

        if (!isEmpty(gcm)) {
            if (!sendMessage.settings) {
                sendMessage.settings = {};
            }
            sendMessage.settings.gcm = gcm;
        }

        var bodyData = JSON.stringify(sendMessage);
        var request = require('request');
        var promise = new Promise(function (resolve, reject) {
            request({
                method: 'post',
                uri: 'https://mobile.ng.bluemix.net/imfpush/v1/apps/' + appId + '/messages',
                headers: {
                    'appSecret': appSecret,
                    'Accept': 'application/json',
                    'Accept-Language': 'en-US',
                    'Content-Type': 'application/json',
                    'Content-Length': bodyData.length
                },
                body: bodyData
            }, function (error, response, body) {
                if (error) {
                    reject(error);
                }
                var j = JSON.parse(body);
                resolve(j);
            });
        });
        return promise;
    }
}

function isEmpty(obj) {
    if (obj === null) return true;
    if (obj.length > 0) return false;
    if (obj.length === 0) return true;
    for (var key in obj) {
        if (hasOwnProperty.call(obj, key)) return false;
    }

    return true;
}

function validateParams(params) {
    if (!params.appId) {
        whisk.error('appId / appGUID of the application is required.');
        return false;
    }
    if (!params.appSecret) {
        whisk.error('appSecret of the application is required.');
        return false;
    }
    return true;
}
