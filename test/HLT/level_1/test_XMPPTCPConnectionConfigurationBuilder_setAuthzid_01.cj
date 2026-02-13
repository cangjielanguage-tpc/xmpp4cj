// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setAuthzid_01(): Unit {
        let id: EntityBareJid = JidCreate.entityBareFrom("test1@xmpp.testserver")
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setAuthzid(id) // 设置用作授权标识的XMPP地址
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
        conn.connect() // 连接
        var iq01=ElementRegister1()
        conn.sendStanza(iq01)
        let e:XmppSaslException=@AssertThrows[XmppSaslException](conn.login())
        println(e.toString())
        @Assert(e.toString().contains("No supported and enabled SASL Mechanism provided by server. Server announced mechanisms: [PLAIN, ANONYMOUS, SCRAM-SHA-1"),true)
        @Assert(e.toString().contains("Registered SASL mechanisms with Xmpp: REGISTERED_MECHANISMS. Enabled SASL mechanisms for this connection: None. Blacklisted SASL mechanisms: [SCRAM-SHA-1-PLUS]. Skip reasons: [Skipping SASL Mech: ANONYMOUS, Prio: 500 because authzid is required by not supported by this SASL mechanism]"),true)
        var iqUn=ElementUnRegister()
        conn.sendStanza(iqUn)
        conn.disconnect()
    }
}
//定义查询当前用户添加联系人
class ElementRegister1 <: Stanza {
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

