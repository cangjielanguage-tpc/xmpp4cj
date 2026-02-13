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
    func test_setXmppDomain_04(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        let domainbareJid=JidCreate.domainBareFrom(XmppTestServerHostName)
        configBuilder.setXmppDomain(domainbareJid)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        connection.disconnect()
    }
}

