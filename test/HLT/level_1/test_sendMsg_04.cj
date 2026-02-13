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
    //不在群聊中，给群聊发消息，error回执
    @TestCase
    func test_sendMsg04_01(): Unit {
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage()
            .ofType(MessageType.groupchat) // 设置消息类型
        testCreateConnSend(msgBuilder,StanzaTypeFilter<Message>.MESSAGE)
    }
}

func testCreateConnSend(msgBuilder:MessageBuilder,msgFilterType:StanzaFilter){
    let syncCounter: SyncCounter = SyncCounter(1)
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    var listner02= StanzaListener2(syncCounter,conn2)
    conn2.addSyncStanzaListener(listner02, msgFilterType) // 添加消息接收回调接口
    conn2.connect() // 连接
    var iq01=ElementRegister9()
    conn2.sendStanza(iq01)
    syncCounter.waitUntilZero(timeout: Duration.second * 2)

    conn2.login("test9", "123456") // 登录
    let name02=conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()

    let roomLocal="groupByHLT01"
    let roomName01= "${roomLocal}@conference.xmpp.testserver"  //群聊id
    
    let roomJid01: EntityBareJid = JidCreate.entityBareFrom(roomName01)
    let msg: Message =msgBuilder.to(roomJid01) // 设置消息的接收方地址
        .setBody("红红火火") // 设置消息正文
        .build()

    conn2.trySendStanza(msg) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    var iq02=ElementUnRegister()
    conn2.sendStanza(iq02)
    conn2.disconnect() // 从服务器断开连接

    var msgRegex01="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name02}@xmpp.testserver.*' from='${roomName01}' type='error'><error type='wait'><recipient-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/><text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'>The room that the message was addressed to is not available.</text></error><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0' id='.*' by='${roomName01}'></stanza-id></message>"
    var matcherMag01 = Regex(msgRegex01,RegexOption().ignoreCase()).matcher(listner02.logContent.toString())
    @Assert(matcherMag01.allCount(),1)
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







