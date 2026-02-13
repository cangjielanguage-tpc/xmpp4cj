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
    func test_instantShutdown_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        @Assert(connection.isConnected(),true)
        connection.instantShutdown()
        @Assert(connection.isConnected(),false)
    }
}

