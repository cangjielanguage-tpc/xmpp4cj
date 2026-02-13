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
    func test_updateUserStatus07_01(): Unit {
        testPresence(PresenceMode.away)
    }
    @TestCase
    func test_updateUserStatus07_02(): Unit {
        testPresence(PresenceMode.chat)
    }
    @TestCase
    func test_updateUserStatus07_03(): Unit {
        testPresence(PresenceMode.available)
    }
    @TestCase
    func test_updateUserStatus07_04(): Unit {
        testPresence(PresenceMode.xa)
    }
    @TestCase
    func test_updateUserStatus07_05(): Unit {
        testPresence(PresenceMode.dnd)
    }
}
//封装流程逻辑：只修改 PresenceMode ,setCompressionEnabled(true)
func testPresence(mode:PresenceMode){
        let syncCounter: SyncCounter = SyncCounter(1)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setCompressionEnabled(true)
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
        var listner01= StanzaListener1(syncCounter,conn1)
        conn1.addSyncStanzaListener(listner01,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口  MessageTypeFilter.NORMAL
        conn1.connect() // 连接
        conn1.login() // 登录
        let name01=conn1.getUser().getOrThrow().getLocalpartOrThrow().toString()
        let presence: Presence = PresenceBuilder
            .buildPresence()
            .setStatus("I'll be away for a while.")
            .setMode(mode)
            .build()
        conn1.sendStanza(presence) // 发送消息



        let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setCompressionEnabled(true)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
        var listner02= StanzaListener1(syncCounter,conn1)
        conn2.addSyncStanzaListener(listner02,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn2.connect() // 连接
        conn2.login() // 登录
        let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
        let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("${name01}@xmpp.testserver")
        let message2: Message = MessageBuilder
            .buildMessage()
            .to(entityBareJid2) // 设置消息的接收方地址
            .ofType(MessageType.chat) // 设置消息类型
            .setBody("message: ${name02}@xmpp.testserver to ${name01}@xmpp.testserver") // 设置消息正文
            .build()

        conn2.trySendStanza(message2) // 发送消息
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        conn2.disconnect() // 从服务器断开连接

        let recvMsg=name01
        let sendMsg=name02
        var msgRegex01="<message xmlns='jabber:client' xml:lang='zh-CN' to='${recvMsg}@xmpp.testserver' from='${sendMsg}@xmpp.testserver/.*' type='chat'><body>message: ${sendMsg}@xmpp.testserver to ${recvMsg}@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.logContent.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02="<message.* to='${sendMsg}@xmpp.testserver' from='${recvMsg}@xmpp.testserver.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.logContent.toString())
        @Assert(matcherMag02.allCount(),0)

}




