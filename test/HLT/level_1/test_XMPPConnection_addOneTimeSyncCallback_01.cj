// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{
    @TestCase
    func test_addOneTimeSyncCallback_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01=StanzaListener1(syncCounter, conn1)
        var filter01= StanzaTypeFilter<Stanza>("Stanza")
        conn1.addOneTimeSyncCallback(lisener01,filter01)
        conn1.connect() // 连接
        conn1.login() // 登录
        syncCounter.waitUntilZero(timeout: Duration.second * 5)
        conn1.disconnect() // 从服务器断开连接
        var logContentCur=lisener01.logContent.toString()
        @Assert(logContentCur.count("<presence"),0)
        @Assert(logContentCur.count("<iq"),1)
        @Assert(logContentCur.count("</iq>"),1)
    }
    @TestCase
    func test_addOneTimeSyncCallback_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01=StanzaListener1(syncCounter, conn1)
        var filter01=StanzaTypeFilter<Message>("Message")
        conn1.addOneTimeSyncCallback(lisener01,filter01)
        conn1.connect()
        conn1.login()
        syncCounter.waitUntilZero(timeout: Duration.second * 5)
        conn1.disconnect() // 从服务器断开连接
        var logContentCur=lisener01.logContent.toString()
        @Assert(logContentCur.count("<presence"),0)
        @Assert(logContentCur.count("<iq"),0)
        @Assert(logContentCur.count("</iq>"),0)
    }
}