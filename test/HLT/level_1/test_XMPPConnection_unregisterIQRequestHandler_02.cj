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
    @TestCase  //注册后注销
    func test_unregisterIQRequestHandler_01(): Unit {
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
        conn1.addAsyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        conn1.registerIQRequestHandler(PingRequestHandler())
        var iqhandler=conn1.unregisterIQRequestHandler("ping", "urn:xmpp:ping", IQType.get).getOrThrow()
        conn1.connect() // 连接
        conn1.login()
        conn1.disconnect() // 从服务器断开连接
        @Assert(iqhandler.getElement().toString(),"ping")
        @Assert(iqhandler.getMode().toString(),"async")
        @Assert(iqhandler.getNamespace().toString(),"urn:xmpp:ping")
        @Assert(iqhandler.getType().toString(),"get")
        @Assert(iqhandler.getQName().toString(),"{urn:xmpp:ping}ping")
    }
    @TestCase   //未注册直接注销
    func test_unregisterIQRequestHandler_02(): Unit {
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
        conn1.addAsyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        var iqhandler=conn1.unregisterIQRequestHandler("ping", "urn:xmpp:ping", IQType.get) //这里注销要和注册时信息对应
        conn1.connect() // 连接
        conn1.login()
        var iq=Session()
        conn1.sendStanza(iq)
        conn1.disconnect() // 从服务器断开连接
        @Assert(iqhandler.isNone(),true)
    }
}
