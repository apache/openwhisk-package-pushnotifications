

# Using the Push package

The `/whisk.system/pushnotifications` package enables you to work with a push service. It includes the following action and feed.

| Entity | Type | Parameters | Description |
| --- | --- | --- | --- |
| `/whisk.system/pushnotifications` | package | appId, appSecret  | Work with the Push Service |
| `/whisk.system/pushnotifications/sendMessage` | action | text, url, deviceIds, platforms, tagNames, apnsBadge, apnsCategory, apnsActionKeyTitle, apnsSound, apnsPayload, apnsType, gcmCollapseKey, gcmDelayWhileIdle, gcmPayload, gcmPriority, gcmSound, gcmTimeToLive | Send push notification to the specified device(s) |
| `/whisk.system/pushnotifications/webhook` | feed | events | Fire trigger events on device activities (device (un)registration / (un)subscription) on the Push Service |
Even though its not mandatory , it's suggested that you create a package binding with the `appId` and `appSecret` values. This way you don't need to specify these credentials every time you invoke the actions in the package.

### Setting up IBM Push Notifications package

While creating a  IBM Push Notifications package you have to give the following parameters,

-  `appId`: The Bluemix app GUID.
-  `appSecret`: The Bluemix push notification service appSecret.

The following is an example of creating a package binding.

1. Create a Bluemix application in [Bluemix Dashboard](http://console.ng.bluemix.net).

2. Initialize the Push Notification Service and bind the service to the Bluemix application

3. Configure the [IBM Push Notification application](https://console.ng.bluemix.net/docs/services/mobilepush/index.html).

   Be sure to remember the `App GUID`  and the `App Secret` of the Bluemix app you created.

4. Make sure your OpenWhisk CLI is in the namespace corresponding to the Bluemix organization and space that you used in the previous step.

 ```
 $ wsk property set --namespace myBluemixOrg_myBluemixSpace
 ```
Alternatively, you can use

 ```
 wsk property set --namespace
 ```

 to set a namespace from a list of those accessible to you.

5. Create a package binding with the `/whisk.system/pushnotifications`.

 ```
  wsk package bind /whisk.system/pushnotifications myPush -p appId "myAppID" -p appSecret "myAppSecret"
 ```

6. Verify that the package binding exists.

 ```
 wsk package list
 ```
 ```
 packages
 /myNamespace/myPush private binding
 ```

### Sending Push Notifications
{: #action parameters}

The `/whisk.system/pushnotifications/sendMessage` action sends push notifications to registered devices. The parameters are as follows:
- `text` - The notification message to be shown to the user. Eg: -p text "Hi ,OpenWhisk send a notification".
- `url`: An optional URL that can be sent along with the alert. Eg : -p url "https:\\www.w3.ibm.com".
- `gcmPayload` - Custom JSON payload that will be sent as part of the notification message. Eg: -p gcmPayload "{"hi":"hello"}"
- `gcmSound` - The sound file (on device) that will be attempted to play when the notification arrives on the device .
- `gcmCollapseKey` - This parameter identifies a group of messages
- `gcmDelayWhileIdle` - When this parameter is set to true, it indicates that the message should not be sent until the device becomes active.
- `gcmPriority` - Sets the priority of the message.
- `gcmTimeToLive` - This parameter specifies how long (in seconds) the message should be kept in GCM storage if the device is offline.
- `apnsBadge` - The number to display as the badge of the application icon.
- `apnsCategory` -  The category identifier to be used for the interactive push notifications .
- `apnsIosActionKey` - The title for the Action key .
- `apnsPayload` - Custom JSON payload that will be sent as part of the notification message.
- `apnsType` - ['DEFAULT', 'MIXED', 'SILENT'].
- `apnsSound` - The name of the sound file in the application bundle. The sound of this file is played as an alert.

Here is an example of sending push notification from the pushnotification package.

1. Send push notification by using the `sendMessage` action in the package binding that you created previously. Be sure to replace `/myNamespace/myPush` with your package name.

```
wsk action invoke /myNamespace/myPush/sendMessage --blocking --result  -p url https://example.com -p text "this is my message3"  -p sound soundFileName -p deviceIds '["T1","T2"]'
```

```
{
"result": {
"pushResponse": "{"messageId":"11111H","message":{"message":{"alert":"this is my message3","url":"http.google.com"},"settings":{"apns":{"sound":"default"},"gcm":{"sound":"default"},"target":{"deviceIds":["T1","T2"]}}}"
},
"status": "success",
"success": true
}
```

### Firing a trigger event on IBM Push Notifications Service activity

The `/whisk.system/pushnotifications/webhook` configures the IBM Push Notifications service to fire a trigger when there is a device activity such as device registration / unregistration or subscription / unsubscription in a specified application

The parameters are as follows:

- `appId:` The Bluemix push notification service appSecret.
- `appSecret:` The Bluemix app GUID.
- `events:` Supported events are `onDeviceRegister`, `onDeviceUnregister`, `onDeviceUpdate`, `onSubscribe`, `onUnsubscribe`.To get notified for all events use the wildcard character `*`.

The following is an example of creating a trigger that will be fired each time there is a new device registered with the IBM Push Notifications Service application.

1. Create a package binding configured for your IBM Push Notifications service with your appId and appSecret.

  ```
  $ wsk package bind /whisk.system/pushnotifications myNewDeviceFeed --param appID myapp --param appSecret myAppSecret --param events onDeviceRegister
  ```

3. Create a trigger for the IBM Push Notifications Service `onDeviceRegister` event type using your `myPush/webhook` feed.

 ```
  $ wsk trigger create myPushTrigger --feed myPush/webhook --param events onDeviceRegister
  ```

### Using Push Package Locally.

You can use the push package actions and feed in your own openWhisk packages. For using it you have to download the Push package form the  [wsk-pkg-pushnotification](https://github.com/openwhisk/wsk-pkg-pushnotifications) repository.

To create your own package follow the below steps,

1. Point to the `wsk-pkg-pushnotification` location.
2. Create the package using `wsk package create package-name` command
3. Add action  using the following command, 

  ```
  wsk action create actionName sendmessage.js -p appId "your_AppID" -p appSecret "application_Secret" -p text "message"
  ```
   
  You can add multiple parameters to sendMessage action. 
  Check for the available parameters [here](#action parameters)

4. Create feed using the following command,
  
   ```
   wsk action create /myNamespace/yourPackageName/webhook webhook.js -a feed true
   ```
   
5. Create a trigger using the feed created above,
   
   ```
   wsk trigger create triggerName --feed /myNamespace/yourPackageName/webhook -p appId "application ID" -p appSecret "app Secret " -p events "onDeviceUnregister" 
   ```

  Output will be like this:
    
    ```
    {
    "response": {
                "name":"triggerName",
                "eventTypes":"onDeviceRegister",
                "url":"https://openWhiskAuth@openwhisk.ng.bluemix.net/api/v1/namespaces/myNamespace/triggers/triggerName"
                }
    }
    ```

6. We need to create a rule that will combine the trigger and the action created in previous steps.Create the rule using ,

   `wsk rule create --enable yourRule  triggerName  actionName `

7. Check the results in the `wsk activation poll`.
8. Register a device in your Bluemix application , you can see the `rule`,`trigger` and  `action` geting executed in the openWhisk [dashboard] (https://new-console.ng.bluemix.net/openwhisk/dashboard). 
9. The action will send a push notification.


## Deploying Push Package using `install.sh`

1. git clone https://github.com/openwhisk/wsk-pkg-pushnotifications
2. cd wsk-pkg-pushnotifications
3. APIHOST="$EDGE_HOST" AUTH="$AUTH_KEY" WSK_CLI="$OPENWHISK_HOME/bin/wsk" ./install.sh
   APIHOST is the OpenWhisk hostname.  AUTH is your auth key.  WSK_CLI is location of the Openwhisk CLI binary.
