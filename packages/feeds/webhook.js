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
 *  @param {string} apiKey - apiKey of the application
 *  @param {string} events - list of the events the webhook should fire on
 *  @return {object} whisk async
 */
module.paths.push('/usr/lib/node_modules');
var https = require('https');
var url = require('url');
var request = require('request');

function main(params) {

    console.log("push trigger feed params: ", params);
    var parsedName = parseQName(params.triggerName);
    var trigger = parsedName.name;
    var namespace = parsedName.namespace;
    var endpoint = 'openwhisk.ng.bluemix.net';
    // URL of the whisk system. The calls of push service will go here.
    var whiskCallbackUrl = 'https://' + process.env.__OW_API_KEY + "@" + endpoint + '/api/v1/namespaces/' + namespace + '/triggers/' + trigger;


    if (!params.appId && !params.appGuid) {
        return Promise.reject('appId / appGUID of the application is required.');
    }
    if (!params.appSecret && !params.apiKey) {
        return Promise.reject('appSecret / apiKey of the application is required.');
    }

    var appId = params.appGuid || params.appId;
    var appSecret = params.appSecret;
    var apiKey = params.apiKey;

    var apiHost;
    if (params.apiHost) {
        apiHost = params.apiHost;
    } else if (params.admin_url) {
        var adminURL = url.parse(params.admin_url).protocol === null ? `https:${params.admin_url}` : params.admin_url;
        apiHost = url.parse(adminURL).host;
    } else {
        apiHost = 'imfpush.ng.bluemix.net';
    }

    // The URL to create the webhook on push service
    var registrationEndpoint = 'https://' + apiHost + '/imfpush/v1/apps/' + appId + '/webhooks';
    var lifecycleEvent = (params.lifecycleEvent || 'CREATE').trim().toUpperCase();

    if (lifecycleEvent === 'CREATE' || lifecycleEvent === 'UPDATE') {

        var events = params.events;
        var body = {
            name: trigger,
            url: whiskCallbackUrl,
            eventTypes: events
        };

        if (!appSecret) {

            return new Promise(function (resolve, reject) {
                getAuthToken(apiKey, apiHost).then(function (response) {
                    if (response.hasToken) {
                        var options = {
                            method: 'POST',
                            url: registrationEndpoint,
                            body: JSON.stringify(body),
                            headers: {
                                'Authorization': "Bearer " + response.apiToken,
                                'Content-Type': 'application/json'
                            }
                        };
                        sendWebhook(options).then(function (response) {
                            resolve(response);
                        }).catch(function (e) {
                            reject(e);
                        });
                    } else {
                        reject({
                            error: "Not able to get a valid iam token"
                        });
                    }
                });
            });
        } else {
            var options = {
                method: 'POST',
                url: registrationEndpoint,
                body: JSON.stringify(body),
                headers: {
                    'appSecret': appSecret,
                    'Content-Type': 'application/json'
                }
            };
            return sendWebhook(options);
        }
    } else if (lifecycleEvent === 'DELETE') {


        if (!appSecret) {

            return new Promise(function (resolve, reject) {
                getAuthToken(apiKey, apiHost).then(function (response) {
                    if (response.hasToken) {
                        var options = {
                            method: 'DELETE',
                            url: registrationEndpoint,
                            headers: {
                                'Authorization': "Bearer " + response.apiToken
                            }
                        };
                        sendWebhook(options).then(function (response) {
                            resolve(response);
                        }).catch(function (e) {
                            reject(e);
                        });
                    } else {
                        reject({
                            error: "Not able to get a valid iam token"
                        });
                    }
                });
            });

        } else {

            var options = {
                method: 'DELETE',
                url: registrationEndpoint,
                headers: {
                    'appSecret': appSecret
                }
            };
            return sendWebhook(options);
        }
    }
}

function sendWebhook(options) {

    var promise = new Promise(function (resolve, reject) {
        request(options, function (error, response, body) {
            if (error) {
                reject(error);
            }
            resolve({
                response: body
            });
        });
    });
    return promise;

}

function getAuthToken(apiKeyId, iamRegion) {

    return new Promise(function (resolve, reject) {
        iamRegion = iamRegion.substring(iamRegion.indexOf('.') + 1);
        var iamUri = "https://iam." + iamRegion + "/identity/token"
        var iamHeaders = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
        };
        var options = {
            uri: iamUri,
            method: "POST",
            headers: iamHeaders,
            form: {
                grant_type: 'urn:ibm:params:oauth:grant-type:apikey',
                apikey: apiKeyId
            }
        };
        request(options, function (error, response, body) {
            if (error) {
                reject({
                    hasToken: false,
                    token: ""
                });
            } else {
                if (response.statusCode == 200) {
                    var responseJson = JSON.parse(body);
                    resolve({
                        hasToken: true,
                        apiToken: responseJson["access_token"]
                    });
                } else {
                    reject({
                        hasToken: false,
                        token: ""
                    });
                }
            }
        });
    });
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