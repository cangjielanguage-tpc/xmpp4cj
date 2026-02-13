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
    func test_setPort_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setPort(5222)
        .setHost(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        @Assert(connection.getPort(),5222)
        connection.disconnect()
    }
    @TestCase
    func test_setPort_02(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setPort(5230)
        .setHost(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        /*connection.connect()

        connection.login()

        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        @Assert(connection.getPort(),5222) */
        connection.disconnect()
    }
}

