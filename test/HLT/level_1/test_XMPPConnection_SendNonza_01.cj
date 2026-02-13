// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.compress.*
import cangjie_tpc::xmpp4cj.stream.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{
    @TestCase
    func test_sendNonza_01(): Unit {   //该场景需手动验证结果，在控制台打印  <a xmlns='urn:xmpp:sm:3' h='1' />和 <r xmlns='urn:xmpp:sm:3'/>各五条
        let tmp=getConnection()
        let conn1=tmp[0]
        let syncCounter=tmp[1]
        conn1.connect()
        conn1.login()
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        conn1.sendNonza(StreamManagementAckRequest.INSTANCE)
        conn1.sendNonza(StreamManagementAckRequest.INSTANCE)
        conn1.sendNonza(StreamManagementAckRequest.INSTANCE)
        conn1.sendNonza(StreamManagementAckRequest.INSTANCE)
        conn1.sendNonza(StreamManagementAckRequest.INSTANCE)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
    }
    func getConnection():(XMPPTCPConnection,SyncCounter){
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .enableDefaultDebugger()
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  (conn1,syncCounter)
    }
}