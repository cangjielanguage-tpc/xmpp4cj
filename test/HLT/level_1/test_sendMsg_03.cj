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
    //双方变更状态，消息交互情况
    //都在群聊中互发消息
    @TestCase
    func test_sendMsg03_01(): Unit {
        //let tmp=testCreateConnRecv(MessageTypeFilter.GROUPCHAT)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.groupchat) // 设置消息类型
        testCreateConnSend(msgBuilder,StanzaTypeFilter<Message>.MESSAGE)
    }
}
//两个用户加入群聊,并发送消息
func testCreateConnSend(msgBuilder:MessageBuilder,msgFilterType:StanzaFilter){
    let syncCounter: SyncCounter = SyncCounter(1)
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    var listner01= StanzaListener1(syncCounter,conn1)
    conn1.addSyncStanzaListener(listner01, msgFilterType) // 添加消息接收回调接口
    conn1.connect() // 连接
    var iq05=ElementRegister5()
    conn1.sendStanza(iq05)
    conn1.login("test5", "123456") // 登录
    let roomLocal="groupByHLT01"
    let roomName01= "${roomLocal}@conference.xmpp.testserver"  //群聊id
    let name01=conn1.getUser().getOrThrow().getLocalpartOrThrow().toString()
    //用户5加入群聊
    let user01Jid: EntityFullJid = JidCreate.entityFullFrom("${roomLocal}@conference.xmpp.testserver/${name01}")
    let presence1: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .ofType(PresenceType.available)
        .to(user01Jid)
        .build()
    conn1.trySendStanza(presence1) // 发送消息

    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    var listner02= StanzaListener2(syncCounter,conn2)
    conn2.addSyncStanzaListener(listner02, msgFilterType) // 添加消息接收回调接口
    conn2.connect() // 连接
    var iq09=ElementRegister9()
    conn2.sendStanza(iq09)
    conn2.login("test9", "123456") // 登录
    let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
    let user02Jid: EntityFullJid = JidCreate.entityFullFrom("${roomLocal}@conference.xmpp.testserver/${name02}")
    let presence2: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .ofType(PresenceType.available)
        .to(user02Jid)
        .build()
    conn2.trySendStanza(presence2) // 发送消息

    let roomJid01: EntityBareJid = JidCreate.entityBareFrom(roomName01)
    let msg: Message =msgBuilder.to(roomJid01) // 设置消息的接收方地址
        .setBody("红红火火") // 设置消息正文
        .build()

    conn2.trySendStanza(msg) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    var iqUn=ElementUnRegister()
    conn1.sendStanza(iqUn)
    conn2.sendStanza(iqUn)
    conn2.disconnect() // 从服务器断开连接
    conn1.disconnect() // 从服务器断开连接
    //用户5加入群聊的断言
    var msgRegex01="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name01}@xmpp.testserver.*' from='${roomName01}' id='.*' type='groupchat'><subject></subject></message>"
    var matcherMag01 = Regex(msgRegex01,RegexOption().ignoreCase()).matcher(listner01.logContent.toString())
    @Assert(matcherMag01.allCount(),1)

    //用户9加入群聊的断言
    var msgRegex02="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name02}@xmpp.testserver.*' from='${roomName01}' id='.*' type='groupchat'><subject></subject></message>"
    var matcherMag02 = Regex(msgRegex02,RegexOption().ignoreCase()).matcher(listner02.logContent.toString())
    @Assert(matcherMag02.allCount(),1)

    //用户5 接收到群聊消息的回执 ,消息来源groupbyhlt01@conference.xmpp.testserver/9
    //和java一致的报文
    var msgRegex03="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name01}@xmpp.testserver.*' from='${roomName01}/${name02}' type='groupchat'><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0' id='.*' by='${roomName01}'></stanza-id><addresses xmlns='http://jabber.org/protocol/address'><address type='ofrom' jid='${name02}@xmpp.testserver'></address></addresses></message>"
    var matcherMag03 = Regex(msgRegex03,RegexOption().ignoreCase()).matcher(listner01.logContent.toString())
    @Assert(matcherMag03.allCount(),1)

    //用户9 接收到群聊消息的回执
    //和java一致的报文
    var msgRegex04="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name02}@xmpp.testserver.*' from='${roomName01}/${name02}' type='groupchat'><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0' id='.*' by='${roomName01}'></stanza-id><addresses xmlns='http://jabber.org/protocol/address'><address type='ofrom' jid='${name02}@xmpp.testserver'></address></addresses></message>"
    var matcherMag04 = Regex(msgRegex04,RegexOption().ignoreCase()).matcher(listner02.logContent.toString())
    @Assert(matcherMag04.allCount(),1)
}

//定义查询当前用户添加联系人
class ElementRegister9 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test9</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
//定义查询当前用户添加联系人
class ElementRegister5 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test5</username><password>123456</password></query></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return "iq"
    }
}









