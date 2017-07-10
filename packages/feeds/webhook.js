/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 *  Feed to create a webhook for IBM Push Notifications service
 *
 *  @param {string} appGuid - appGuid to create webhook
 *  @param {string} appSecret - appSecret of the application
 *  @param {string} events - list of the events the webhook should fire on
 *  @return {object} whisk async
 */
var request = require('request');

function main(params) {

    console.log("push trigger feed params: ", params);
    var parsedName = parseQName(params.triggerName);
    var trigger = parsedName.name;
    var namespace = parsedName.namespace;
    var endpoint = 'openwhisk.ng.bluemix.net';
    // URL of the whisk system. The calls of push service will go here.
    var whiskCallbackUrl = 'https://' + process.env.__OW_API_KEY + "@" + endpoint + '/api/v1/namespaces/' + namespace + '/triggers/' + trigger;
    var appId = params.appGuid || params.appId;
    var appSecret = params.appSecret;
    // The URL to create the webhook on push service
    var registrationEndpoint = 'https://mobile.ng.bluemix.net/imfpush/v1/apps/' + appId + '/webhooks';
    var lifecycleEvent = (params.lifecycleEvent || 'CREATE').trim().toUpperCase();
    if (lifecycleEvent === 'CREATE' || lifecycleEvent === 'UPDATE') {

        var events = params.events;
        var body = {
            name:trigger,
            url: whiskCallbackUrl,
            eventTypes: events
        };
        var options = {
            method: 'POST',
            url: registrationEndpoint,
            body: JSON.stringify(body),
            headers: {
                'appSecret': appSecret,
                'Content-Type': 'application/json'
            }
        };
        var promise = new Promise(function(resolve, reject) {
            request(options, function (error, response, body) {
                if (error) {
                    reject(error);
                }
                resolve({response: body});
            });
        });

        return promise;
    } else if (lifecycleEvent === 'DELETE') {
        var options = {
            method: 'DELETE',
            url: registrationEndpoint,
            headers: {
                'appSecret': appSecret
            }
        };
        var promise = new Promise(function(resolve, reject) {
            request(options, function (error, response, body) {
                if (error) {
                    reject(error);
                }
                resolve({response: body});
            });
        });

        return promise;
    }
}

function parseQName(qname) {
    var parsed = {};
    var delimiter = '/';
    var defaultNamespace = '_';
    if (qname && qname.charAt(0) === delimiter) {
        var parts = qname.split(delimiter);
        parsed.namespace = parts[1];
        parsed.name = parts.length > 2 ? parts.slice(2).join(delimiter) : '';
    } else {
        parsed.namespace = defaultNamespace;
        parsed.name = qname;
    }
    return parsed;
}
