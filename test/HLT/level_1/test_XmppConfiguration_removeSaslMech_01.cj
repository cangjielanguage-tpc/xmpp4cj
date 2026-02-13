// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.time.*

@Test
public class TestXmppConfiguration{
    @TestCase
    func test_XmppConfiguration_removeSaslMech_01(): Unit {
        var saslMechsOri:Array<String>=["Other","My"]
        XmppConfiguration.addSaslMechs(saslMechsOri)
        XmppConfiguration.removeSaslMech("Other")
        var saslMechs=XmppConfiguration.getSaslMechs()
        @Assert(saslMechs.size,1)
    }
    @TestCase
    func test_XmppConfiguration_removeSaslMech_02(): Unit {
        var saslMechsOri:Array<String>=["Other","My"]
        XmppConfiguration.addSaslMechs(saslMechsOri)
        XmppConfiguration.removeSaslMech("you")
        var saslMechs=XmppConfiguration.getSaslMechs()
        @Assert(saslMechs.size,2)
    }
}