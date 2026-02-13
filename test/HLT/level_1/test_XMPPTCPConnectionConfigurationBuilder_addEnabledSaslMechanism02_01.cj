// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.sasl.*
import std.time.*
import stdx.net.*
import stdx.net.tls.*
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_test_addEnabledSaslMechanism02_04(): Unit {
        let saslMechanismStrs=["ANONYMOUS","SCRAM-SHA-1"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        config.addEnabledSaslMechanism(saslMechanismStrs)
        var conn: AbstractXMPPConnection = XMPPTCPConnection(config.build())
        conn.connect()
        var iq01=ElementRegister()
        conn.sendStanza(iq01)
        conn.login("test1", "123456")
        @Assert(conn.isConnected(),true)
        @Assert(conn.isAuthenticated(),true)
        var iq02=ElementUnRegister()
        conn.sendStanza(iq02)
        conn.disconnect()
    }
}
//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test1</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}