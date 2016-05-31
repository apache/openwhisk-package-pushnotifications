

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
  val url = credentials.get("url");
  val appId = url.split("/").last;
  var MessageText = "This is pushnotifications Testing";
    
    behavior of "Push Package"
    
   it should "Send Notification action" in {
            val name = "/whisk.system/pushnotifications/sendMessage"
             withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appId" -> appId, "text" -> MessageText), blocking = true, result = true)){
                _.fields("response").toString should include ("pushnotifications")
             }
    }
    
   it should "Send Notification action with url" in {
            val name = "/whisk.system/pushnotifications/sendMessage"
            withActivation(wsk.activation,wsk.action.invoke(name, Map("appSecret" -> appSecret, "appId" -> appId, "text" -> MessageText, "url"-> "https://w3.ibm.com"), blocking = true, result = true){
               _.fields("response").toString should include ("pushnotifications")
             }
    } 
}