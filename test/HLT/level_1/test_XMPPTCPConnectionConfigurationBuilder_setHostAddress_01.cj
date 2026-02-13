// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setHostAddress_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        let ips=IPAddress.resolve(XmppTestServerHostName)
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setHostAddress(ips[0])
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        @Assert(connection.isConnected(),true)
        connection.login()
        @Assert(connection.isAuthenticated(),true)
        connection.disconnect()
        @Assert(connection.isConnected(),false)
    }
}

