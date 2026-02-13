// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.time.*

@Test
public class TestXmppConfiguration{
    @TestCase
    func test_XmppConfiguration_setStanzaCollectorSize_01(): Unit {
        XmppConfiguration.setStanzaCollectorSize(3)
        @Assert(XmppConfiguration.getStanzaCollectorSize(),3)
    }
    @TestCase
    func test_XmppConfiguration_setStanzaCollectorSize_02(): Unit {
        XmppConfiguration.setStanzaCollectorSize(-1)
        @Assert(XmppConfiguration.getStanzaCollectorSize(),-1)
    }
}