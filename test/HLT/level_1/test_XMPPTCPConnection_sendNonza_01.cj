// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.compress.*
import cangjie_tpc::xmpp4cj.compression.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import stdx.log.*
import std.sync.SyncCounter
var caseNum=0
@Test
public class TestXMPPTCPConnection{
    @TestCase
    func test_sendNonza_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        var listen01=StanzaListener1(syncCounter, connection)
        connection.addSyncStanzaListener(listen01,  StanzaTypeFilter<Stanza>("Stanza"))
        connection.connect()
        connection.login()
        var nonza=Compress("zlib")
        connection.sendNonza(nonza)
        @Assert(connection.isConnected(),true)
        connection.disconnect()
        @Assert(listen01.logContent.toString().isEmpty(),false)
    }
}