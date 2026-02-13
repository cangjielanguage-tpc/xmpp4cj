// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import stdx.log.*
import std.sync.SyncCounter

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setLanguage_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setLanguage("usa")
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        var listen01=StanzaListener1(syncCounter, connection)
        connection.addSyncStanzaListener(listen01, StanzaTypeFilter<Stanza>("Stanza"))
        connection.connect()
        @Assert(connection.isConnected(),true)
        connection.login()
        @Assert(connection.isAuthenticated(),true)
        connection.disconnect()
        @Assert(connection.isConnected(),false)
        @Assert(listen01.logContent.toString().contains("xml:lang=\'usa\'"),true)
    }
}
