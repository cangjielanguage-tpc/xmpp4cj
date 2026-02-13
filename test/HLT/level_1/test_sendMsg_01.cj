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
    func test_sendMsg01_01(): Unit {
        let tmp=testCreateConnRecv(MessageTypeFilter.CHAT)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.chat) // 设置消息类型
        testCreateConnSend(msgBuilder,tmp[0],tmp[1],tmp[2],MessageTypeFilter.CHAT)
    }
    @TestCase
    func test_sendMsg01_02(): Unit {
        let tmp=testCreateConnRecv(MessageTypeFilter.NORMAL)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.normal) // 设置消息类型
        testCreateConnSend(msgBuilder,tmp[0],tmp[1],tmp[2],MessageTypeFilter.NORMAL)
    }
    @TestCase
    func test_sendMsg01_03(): Unit {
        let tmp=testCreateConnRecv(MessageTypeFilter.GROUPCHAT)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.groupchat) // 设置消息类型
        testCreateConnSendFail(msgBuilder,tmp[0],tmp[1],tmp[2],StanzaTypeFilter<Message>.MESSAGE)
    }
    @TestCase
    func test_sendMsg01_04(): Unit {
        let tmp=testCreateConnRecv(MessageTypeFilter.HEADLINE)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.headline) // 设置消息类型
        testCreateConnSend(msgBuilder,tmp[0],tmp[1],tmp[2],StanzaTypeFilter<Message>.MESSAGE)
    }
    @TestCase
    func test_sendMsg01_05(): Unit {
        let tmp=testCreateConnRecv(MessageTypeFilter.ERROR)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.error) // 设置消息类型
        testCreateConnSendInvalid(msgBuilder,tmp[0],tmp[1],tmp[2],MessageTypeFilter.ERROR)
    }
}
//封装流程逻辑：只修改 PresenceMode
func testCreateConnRecv(msgType:StanzaFilter):(XMPPTCPConnection,String,StanzaListener1){
    let syncCounter: SyncCounter = SyncCounter(1)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
    var listner01= StanzaListener1(syncCounter,conn1)
    conn1.addSyncStanzaListener(listner01, msgType) // 添加消息接收回调接口
    conn1.connect() // 连接
    var iq12=ElementRegister12()
    conn1.sendStanza(iq12)
    conn1.login("test12", "123456") // 登录
    let name01=conn1.getUser().getOrThrow().getLocalpartOrThrow().toString()
    return (conn1,name01,listner01)
}

func testCreateConnSend(msgBuilder:MessageBuilder,conn1:XMPPTCPConnection,name01:String,listner01:StanzaListener1,msgType:StanzaFilter){
    let syncCounter: SyncCounter = SyncCounter(1)
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    var listner02= StanzaListener1(syncCounter,conn2)
    conn2.addSyncStanzaListener(listner02, msgType) // 添加消息接收回调接口
    conn2.connect() // 连接
    var iq11=ElementRegister11()
    conn2.sendStanza(iq11)
    conn2.login("test11", "123456") // 登录
    let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
    let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("${name01}@xmpp.testserver")
    let msg: Message =msgBuilder.to(entityBareJid2) // 设置消息的接收方地址
        .setBody("message: ${name02}@xmpp.testserver to ${name01}@xmpp.testserver") // 设置消息正文
        .build()

    conn2.trySendStanza(msg) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    var iqUn=ElementUnRegister()
    conn1.sendStanza(iqUn)
    conn2.sendStanza(iqUn)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
    let recvMsg=name01
    let sendMsg=name02
    var msgRegex01="<message xmlns='jabber:client' xml:lang='zh-CN' to='${recvMsg}@xmpp.testserver' from='${sendMsg}@xmpp.testserver/.*' type='${msg.getType().getOrThrow()}'><body>message: ${sendMsg}@xmpp.testserver to ${recvMsg}@xmpp.testserver</body></message>"
    var matcherMag01 = Regex(msgRegex01).matcher(listner01.logContent.toString())
    @Assert(matcherMag01.allCount(),1)
    var msgRegex02="<message.*to='${name02}@xmpp.testserver.*' from='${name01}@xmpp.testserver.*>"
    var matcherMag02 = Regex(msgRegex02).matcher(listner02.logContent.toString())
    @Assert(matcherMag02.allCount(),0)
}
func testCreateConnSendInvalid(msgBuilder:MessageBuilder,conn1:XMPPTCPConnection,name01:String,listner01:StanzaListener1,msgType:StanzaFilter){
    let syncCounter: SyncCounter = SyncCounter(1)
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    var listner02= StanzaListener1(syncCounter,conn2)
    conn2.addSyncStanzaListener(listner02, msgType) // 添加消息接收回调接口
    conn2.connect() // 连接
    var iq11=ElementRegister11()
    conn2.sendStanza(iq11)
    conn2.login("test11", "123456") // 登录
    let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
    let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("${name01}@xmpp.testserver")
    let msg: Message =msgBuilder.to(entityBareJid2) // 设置消息的接收方地址
        .setBody("message: ${name02}@xmpp.testserver to ${name01}@xmpp.testserver") // 设置消息正文
        .build()

    conn2.trySendStanza(msg) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    var iqUn=ElementUnRegister()
    conn1.sendStanza(iqUn)
    conn2.sendStanza(iqUn)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
    let recvMsg=name01
    let sendMsg=name02
    //这里发送失败，conn1没有发送有效报文,报文不做发送，在交互过程中无体现
    var msgRegex01="<message xmlns='jabber:client' xml:lang='zh-CN' to='${recvMsg}@xmpp.testserver' from='${sendMsg}@xmpp.testserver/.*' type='${msg.getType().getOrThrow()}'><body>message: ${sendMsg}@xmpp.testserver to ${recvMsg}@xmpp.testserver</body></message>"
    var matcherMag01 = Regex(msgRegex01).matcher(listner01.logContent.toString())
    @Assert(matcherMag01.allCount(),0)
    var msgRegex02="<message.*to='${name02}@xmpp.testserver.*' from='${name01}@xmpp.testserver.*>"
    var matcherMag02 = Regex(msgRegex02).matcher(listner02.logContent.toString())
    @Assert(matcherMag02.allCount(),0)
}
func testCreateConnSendFail(msgBuilder:MessageBuilder,conn1:XMPPTCPConnection,name01:String,listner01:StanzaListener1,msgType:StanzaFilter){
    let syncCounter: SyncCounter = SyncCounter(1)
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    var listner02= StanzaListener1(syncCounter,conn2)
    conn2.addSyncStanzaListener(listner02, msgType) // 添加消息接收回调接口
    conn2.connect() // 连接
    var iq11=ElementRegister11()
    conn2.sendStanza(iq11)
    conn2.login("test11", "123456") // 登录
    let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
    let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("${name01}@xmpp.testserver")
    let msg: Message =msgBuilder.to(entityBareJid2) // 设置消息的接收方地址
        .setBody("message: ${name02}@xmpp.testserver to ${name01}@xmpp.testserver") // 设置消息正文
        .build()

    conn2.trySendStanza(msg) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    var iqUn=ElementUnRegister()
    conn1.sendStanza(iqUn)
    conn2.sendStanza(iqUn)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
    let recvMsg=name01
    let sendMsg=name02
    //这里发送失败，conn1没有接收到相关报文,报文回退给conn2
    var msgRegex01="<message.*to='${name02}@xmpp.testserver.*' from='${name01}@xmpp.testserver.*>"
    var matcherMag01 = Regex(msgRegex01).matcher(listner01.logContent.toString())
    @Assert(matcherMag01.allCount(),0)
    var msgRegex02="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name02}@xmpp.testserver.*' from='${name01}@xmpp.testserver.*' type='error'><error type='cancel'><service-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/></error><body>message: ${name02}@xmpp.testserver to ${name01}@xmpp.testserver</body></message>"
    var matcherMag02 = Regex(msgRegex02).matcher(listner02.logContent.toString())
    @Assert(matcherMag02.allCount(),1)
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
class ElementRegister11 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test11</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
