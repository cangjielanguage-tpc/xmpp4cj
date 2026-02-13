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

var caseNum=0
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    @BeforeAll
    func setUp(){
        let syncCounter: SyncCounter = SyncCounter(1)
        let XmppTestServerHostName = "xmpp.testserver"
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setStanzaIdSourceFactory(UuidStanzaIdSourceFactory())
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn2: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn2.addSyncStanzaListener(StanzaListener1(syncCounter, conn2), StanzaAllFilter()) // 添加消息接收回调接口
        conn2.connect() // 连接
        var iq01=ElementRegister10()
        conn2.sendStanza(iq01)
        var iq02=ElementRegister12()
        conn2.sendStanza(iq02)
        conn2.disconnect()
    }
    @AfterAll 
    func tearDown(){
        let syncCounter: SyncCounter = SyncCounter(1)
        let XmppTestServerHostName = "xmpp.testserver"
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setStanzaIdSourceFactory(UuidStanzaIdSourceFactory())
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn3: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn3.addSyncStanzaListener(StanzaListener1(syncCounter, conn3), StanzaAllFilter()) // 添加消息接收回调接口
        conn3.connect() // 连接
        conn3.login("test10", "123456") // 登录
        var iq03=ElementUnRegister()
        conn3.sendStanza(iq03)
        conn3.disconnect()
        let conn4: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn4.connect() // 连接
        conn4.login("test12", "123456") // 登录
        conn4.sendStanza(iq03)
        conn4.disconnect()
    }
    @TestCase
    func test_setStanzaIdSourceFactory_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        var uuidFactory=RandomStringStanzaIdSourceFactory(40,true)
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setStanzaIdSourceFactory(uuidFactory)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var listner01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(listner01, StanzaAllFilter()) // 添加消息接收回调接口
        conn1.connect() // 连接
        conn1.login("test12", "123456") // 登录
        let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("test10@xmpp.testserver")
        let message2: Message = MessageBuilder
            .buildMessage()
            .to(entityBareJid2) // 设置消息的接收方地址
            .ofType(MessageType.chat) // 设置消息类型
            .setBody("message: test12@xmpp.testserver to test10@xmpp.testserver") // 设置消息正文
            .build()
        conn1.sendStanza(message2) // 发送消息
        conn1.disconnect()
    }
    @TestCase
    func test_setStanzaIdSourceFactory_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var listner01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(listner01, StanzaAllFilter()) // 添加消息接收回调接口
        conn1.connect() // 连接
        conn1.login("test12", "123456") // 登录
        let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("test10@xmpp.testserver")
        let message2: Message = MessageBuilder
            .buildMessage()
            .to(entityBareJid2) // 设置消息的接收方地址
            .ofType(MessageType.chat) // 设置消息类型
            .setBody("message: test12@xmpp.testserver to test10@xmpp.testserver") // 设置消息正文
            .build()
        conn1.sendStanza(message2) // 发送消息
        println(listner01.logContent.toString())
        conn1.disconnect()
    }
}
//定义查询当前用户添加联系人
class ElementRegister12 <: Stanza {
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
//定义查询当前用户添加联系人
class ElementRegister10<: Stanza {
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


