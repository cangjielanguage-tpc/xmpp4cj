// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.time.*

@Test
public class TestXmppConfiguration{
    @TestCase
    func test_XmppConfiguration_setDefaultParsingExceptionCallback_01(): Unit {
        var myParsingExceptionCallback=MyParsingExceptionCallback()
        XmppConfiguration.setDefaultParsingExceptionCallback(myParsingExceptionCallback)
        var getRsult= (XmppConfiguration.getDefaultParsingExceptionCallback() as MyParsingExceptionCallback).getOrThrow()
        @Assert(getRsult.toString(),"MyParsingExceptionCallback")
    }
}

public class MyParsingExceptionCallback <: ParsingExceptionCallback & ToString{
   public func handleUnparsableStanza(stanzaData:UnparseableStanza):Unit{

   }
   public func toString():String{
      return "MyParsingExceptionCallback"
   }
}