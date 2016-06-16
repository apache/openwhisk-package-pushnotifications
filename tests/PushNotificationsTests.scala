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
package catalog

import org.junit.runner.RunWith
import org.scalatest.junit.JUnitRunner

import common.TestHelpers
import common.Wsk
import common.WskProps
import common.WskTestHelpers
import spray.json.DefaultJsonProtocol.StringJsonFormat
import spray.json.pimpAny
import common._

@RunWith(classOf[JUnitRunner])
class grtg
    extends TestHelpers
    with WskTestHelpers{
  implicit val wskprops = WskProps()
  val wsk = new Wsk()
  val credentials = TestUtils.getVCAPcredentials("imfpush")
  val appSecret = credentials.get("appSecret");
  val credentialsUrl = credentials.get("url");
  val appId = credentialsUrl.split("/").last;
  val url = "www.google.com".toJson;

  val messageText = "This is pushnotifications Testing".toJson;

  behavior of "Push Package"

    it should "Send Notification action" in {
           val name = "/whisk.system/pushnotifications/sendMessage"
             withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appId" -> appId, "text" -> messageText), blocking = true, result = true)){
                _.fields("response").toString should include ("pushnotifications")
             }
    }

    it should "Send Notification action with url" in {
            val name = "/whisk.system/pushnotifications/sendMessage"
            withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appId" -> appId, "text" -> messageText, "url"-> url), blocking = true, result = true)){
               _.fields("response").toString should include ("pushnotifications")
             }
           }
}
