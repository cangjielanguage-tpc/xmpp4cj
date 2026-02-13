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
    func test_allowEmptyOrNullUsernames_01(): Unit {
        let id: EntityBareJid = JidCreate.entityBareFrom("1@xmpp.testserver")
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) 
            .allowEmptyOrNullUsernames()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
        conn.connect()
        let e:SASLErrorException=@AssertThrows[SASLErrorException](conn.login("", "123456") )
        @Assert(e.toString(),"SASLErrorException: SASLError using SCRAM-SHA-1: Some(not-authorized)")
    }
    @TestCase
    func test_allowEmptyOrNullUsernames_02(): Unit {
        let id: EntityBareJid = JidCreate.entityBareFrom("1@xmpp.testserver")
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
        conn.connect()
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](conn.login("", "123456") )
        @Assert(e.toString(),"IllegalArgumentException: Username must not be null nor empty")
    }
}

