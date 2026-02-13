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
var caseNum=0
@Test
public class TestXMPPTCPConnection{
    @TestCase
    func test_isUsingCompression_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setCompressionEnabled(true) 
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isUsingCompression(),true)
        connection.disconnect()
    }
    @TestCase
    func test_isUsingCompression_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setCompressionEnabled(false)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isUsingCompression(),false)
        connection.disconnect()
    }
    @TestCase
    func test_isUsingCompression_03(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isUsingCompression(),false)
        connection.disconnect()
    }
}

