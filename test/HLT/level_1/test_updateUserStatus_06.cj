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
public class TestUser{
    @TestCase
    func test_updateUserStatus06_01(): Unit {
        testPresence(PresenceMode.away)
    }
    @TestCase
    func test_updateUserStatus06_02(): Unit {
        testPresence(PresenceMode.chat)
    }
    @TestCase
    func test_updateUserStatus06_03(): Unit {
        testPresence(PresenceMode.available)
    }
    @TestCase
    func test_updateUserStatus06_04(): Unit {
        testPresence(PresenceMode.xa)
    }
    @TestCase
    func test_updateUserStatus06_05(): Unit {
        testPresence(PresenceMode.dnd)
    }
}
//封装流程逻辑：只修改 PresenceMode, setCompressionEnabled(true)
func testPresence(mode:PresenceMode){
        let syncCounter: SyncCounter = SyncCounter(1)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setCompressionEnabled(true)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
        var listner01= StanzaListener1(syncCounter,conn1)
        conn1.addSyncStanzaListener(listner01,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn1.connect() // 连接
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        conn1.login("test12", "123456") // 登录

        let presence: Presence = PresenceBuilder
            .buildPresence()
            .setStatus("I'll be away for a while.")
            .setMode(mode)
            .build()
        conn1.sendStanza(presence) // 发送消息

        let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .setCompressionEnabled(true)
            .performSaslAnonymousAuthentication()
            .build()
        let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
        var listner02= StanzaListener1(syncCounter,conn1)
        conn2.addSyncStanzaListener(listner02,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn2.connect() // 连接
        conn2.login() // 登录
        let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
        let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("test12@xmpp.testserver")
        let message2: Message = MessageBuilder
            .buildMessage()
            .to(entityBareJid2) // 设置消息的接收方地址
            .ofType(MessageType.chat) // 设置消息类型
            .setBody("message: ${name02}@xmpp.testserver to test12@xmpp.testserver") // 设置消息正文
            .build()

        conn2.trySendStanza(message2) // 发送消息
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect() // 从服务器断开连接
        conn2.disconnect() // 从服务器断开连接

        let recvMsg="test12"
        let sendMsg=name02
        var msgRegex01="<message xmlns='jabber:client' xml:lang='zh-CN' to='${recvMsg}@xmpp.testserver' from='${sendMsg}@xmpp.testserver/.*' type='chat'><body>message: ${sendMsg}@xmpp.testserver to ${recvMsg}@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.logContent.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02="<message.* to='${sendMsg}@xmpp.testserver' from='${recvMsg}@xmpp.testserver.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.logContent.toString())
        @Assert(matcherMag02.allCount(),0)
}
//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test12</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}



