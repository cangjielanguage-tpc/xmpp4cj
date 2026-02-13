// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.net.*
import std.fs.*
import std.sync.SyncCounter
import stdx.log.*
import std.io.*
import std.time.*

var caseNum=0
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setSendPresence_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSendPresence(true)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var listen01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(listen01, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn1.connect() // 连接
        var iq01=ElementRegister10()
        conn1.sendStanza(iq01)
        conn1.login("test10", "123456") // 登录
        let presence: Presence = PresenceBuilder
            .buildPresence()
            .setStatus("I'll be away for a while.")
            .setMode(PresenceMode.available)
            .build()
        conn1.sendStanza(presence)
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect()
        @Assert(listen01.logContent.toString().count("<presence"),2)
        @Assert(listen01.logContent.toString().count("<iq"),3)
    }
    @TestCase
    func test_setSendPresence_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSendPresence(false)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var listen01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(listen01, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn1.connect() // 连接
        var iq01=ElementRegister10()
        conn1.sendStanza(iq01)
        conn1.login("test10", "123456") // 登录
        let presence: Presence = PresenceBuilder
            .buildPresence()
            .setStatus("I'll be away for a while.")
            .setMode(PresenceMode.available)
            .build()
        conn1.sendStanza(presence)
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect()
        @Assert(listen01.logContent.toString().count("<presence"),1)
        @Assert(listen01.logContent.toString().count("<iq"),3)
    }
}
//定义查询当前用户添加联系人
class ElementRegister10 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test10</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
