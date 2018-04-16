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
package packages

import common.{TestHelpers, Wsk, WskProps, WskTestHelpers, _}
import org.junit.runner.RunWith
import org.scalatest.junit.JUnitRunner
import spray.json.DefaultJsonProtocol._
import spray.json._

@RunWith(classOf[JUnitRunner])
class PushNotificationsTests
    extends TestHelpers
    with WskTestHelpers{
  implicit val wskprops = WskProps()
  val wsk = new Wsk()
  val credentials = TestUtils.getVCAPcredentials("imfpush")
  val appSecret = credentials.get("appSecret").toJson;
  val credentialsUrl = credentials.get("url");
  val adminURL = credentials.get("admin_url");
  val apiHost = adminURL.split("/")(2);
  val appGuid = credentialsUrl.split("/").last.toJson;
  val url = "www.google.com".toJson;

  val messageText = "This is pushnotifications Testing".toJson;
  val unicodeMessage = "\ue04a".toJson;
  val accentMessage = "Máxima de 33 C and Mínima de 26 C".toJson;

  behavior of "Push Package"

    it should "Send Notification action" in {
           val name = "/whisk.system/pushnotifications/sendMessage"
             withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> messageText))){
                 _.response.result.get.toString should include ("message")
             }
    }

    it should "Send Notification action with unicode message" in {
           val name = "/whisk.system/pushnotifications/sendMessage"
             withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> unicodeMessage))){
                 _.response.result.get.toString should include ("message")
             }
    }

    it should "Send Notification action with accent message" in {
           val name = "/whisk.system/pushnotifications/sendMessage"
             withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> accentMessage))){
                 _.response.result.get.toString should include ("message")
             }
    }

    it should "Send Notification action with url" in {
            val name = "/whisk.system/pushnotifications/sendMessage"
            withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> messageText, "url"-> url))){
                _.response.result.get.toString should include ("message")
             }
           }

    it should "Send Notification action using admin_url" in {
        val name = "/whisk.system/pushnotifications/sendMessage"
        withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> messageText, "admin_url"-> adminURL.toJson))){
            _.response.result.get.toString should include ("message")
        }
    }

    it should "Send Notification action using bad admin_url" in {
        val name = "/whisk.system/pushnotifications/sendMessage"
        withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> messageText, "admin_url"-> "//mobile.bad.host/pathname".toJson))){
            _.response.success shouldBe false
        }
    }

    it should "Send Notification action using apiHost" in {
        val name = "/whisk.system/pushnotifications/sendMessage"
        withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> messageText, "apiHost"-> apiHost.toJson))){
            _.response.result.get.toString should include ("message")
        }
    }

    it should "Send Notification action using bad apiHost" in {
        val name = "/whisk.system/pushnotifications/sendMessage"
        withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appGuid" -> appGuid, "text" -> messageText, "apiHost"-> "mobile.bad.host".toJson))){
            _.response.success shouldBe false
        }
    }
}
