// DEPENDENCE: ./commonHLT.cj ../log.cj ../z_test.cj
// EXEC: cjc %import-path %L %l %f log.cj z_test.cj commonHLT.cj --test
// EXEC: ./main 
//--filter=*.*
/// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
/// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
/// dependence: ../commonHLT.cj

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
public class TestUser {
    //双方变更状态，消息交互情况
    //发送对象(非匿名-非匿名)在PresenceMode的各种情况下，是否能发送消息
    @TestCase
    func test_sendMsg03_01(): Unit {
        //let tmp=testCreateConnRecv(MessageTypeFilter.GROUPCHAT)
        let msgBuilder: MessageBuilder = MessageBuilder.buildMessage().ofType(MessageType.groupchat) // 设置消息类型
        testCreateConnSendTry(msgBuilder, StanzaTypeFilter<Message>.MESSAGE)
    }
}
//两个用户加入群聊,并发送消息
func testCreateConnSend(msgBuilder: MessageBuilder, msgFilterType: StanzaFilter) {
    let res = StringBuilder()

    let syncCounter: SyncCounter = SyncCounter(1)
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        // .enableDefaultDebugger() // 开启调试模式
        .setDebuggerFactory(Debugger0Factory()) // 设置调试器
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    var listner01 = StanzaListener1(syncCounter, conn1)
    conn1.addSyncStanzaListener(listner01, msgFilterType) // 添加消息接收回调接口
    conn1.connect() // 连接
    conn1.login("5", "123456") // 登录
    let roomLocal = "groupByHLT01"
    let roomName01 = "${roomLocal}@conference.xmpp.testserver" //群聊id
    let name01 = conn1.getUser().getOrThrow().getLocalpartOrThrow().toString()
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
    var listner02 = StanzaListener2(syncCounter, conn2)
    conn2.addSyncStanzaListener(listner02, msgFilterType) // 添加消息接收回调接口
    conn2.connect() // 连接
    conn2.login("9", "123456") // 登录
    let name02 = conn2.getUser().getOrThrow().getLocalpartOrThrow().toString()
    let user02Jid: EntityFullJid = JidCreate.entityFullFrom("${roomLocal}@conference.xmpp.testserver/${name02}")
    let presence2: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .ofType(PresenceType.available)
        .to(user02Jid)
        .build()
    conn2.trySendStanza(presence2) // 发送消息

    let roomJid01: EntityBareJid = JidCreate.entityBareFrom(roomName01)
    let msg: Message = msgBuilder.to(roomJid01) // 设置消息的接收方地址
        .setBody("红红火火") // 设置消息正文
        .build()

    addSendingListener(conn2)

    conn2.trySendStanza(msg) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn2.disconnect() // 从服务器断开连接

    conn1.disconnect() // 从服务器断开连接

    //用户5加入群聊的断言
    var msgRegex01 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='${name01}@xmpp.testserver.*' from='${roomName01}' id='.*' type='groupchat'><subject></subject></message>"
    var matcherMag01 = Regex(msgRegex01, RegexOption().ignoreCase()).matcher(listner01.logContent.toString())
    @Assert(matcherMag01.allCount(),1)

    //用户9加入群聊的断言
    var msgRegex02 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='${name02}@xmpp.testserver.*' from='${roomName01}' id='.*' type='groupchat'><subject></subject></message>"
    var matcherMag02 = Regex(msgRegex02, RegexOption().ignoreCase()).matcher(listner02.logContent.toString())
    @Assert(matcherMag02.allCount(),1)

    //用户5 接收到群聊消息的回执

    //var msgRegex03="<message xmlns='jabber:client' xml:lang='zh-CN' to='${name01}@xmpp.testserver.*' from='${roomName01}/${name01}' type='groupchat'><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0' id='.*' by='${roomName01}'></stanza-id><addresses xmlns='http://jabber.org/protocol/address'><address type='ofrom' jid='${name01}@xmpp.testserver'></address></addresses></message>"
    var msgRegex03 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='${name01}@xmpp.testserver.*' from='${roomName01}/${name02}' type='groupchat'><body>.*</body><stanza-id xmlns='urn:xmpp:sid:0' id='.*' by='${roomName01}'></stanza-id><addresses xmlns='http://jabber.org/protocol/address'><address type='ofrom' jid='${name02}@xmpp.testserver'></address></addresses></message>"
    var matcherMag03 = Regex(msgRegex03, RegexOption().ignoreCase()).matcher(listner01.logContent.toString())
    println("===================listner01.logContent.toString()====================================")
    println("${listner01.logContent.toString()}")

    @Assert(matcherMag03.allCount(),1)

    //用户9 接收到群聊消息的回执
    var msgRegex04 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='${name02}@xmpp.testserver.*' from='${roomName01}/${name02}' type='groupchat'><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0' id='.*' by='${roomName01}'></stanza-id><addresses xmlns='http://jabber.org/protocol/address'><address type='ofrom' jid='${name02}@xmpp.testserver'></address></addresses></message>"
    var matcherMag04 = Regex(msgRegex04, RegexOption().ignoreCase()).matcher(listner02.logContent.toString())
    @Assert(matcherMag04.allCount(),1)

}

func testCreateConnSendTry(msgBuilder: MessageBuilder, msgFilterType: StanzaFilter) {
    try {
        testCreateConnSend(msgBuilder, msgFilterType)
    } finally {
        sleep(Duration.second)
        // println("res:<--\n${Debugger0.res}\n-->")
    }
}

func addSendingListener(conn: XMPPTCPConnection) {
    // 监听修改后Message
    conn.addStanzaSendingListener(
        SimpleStanzaListener {
            stanza => println("sending : ${stanza.toXML()}")
        },
        MessageWithBodiesFilter.INSTANCE
    )
}

class SimpleStanzaListener <: StanzaListener {
    /* customFunc : listener触发时的自定义操作 */
    public SimpleStanzaListener(let customFunc: (Stanza) -> Unit) {}
    public override func processStanza(packet: Stanza) {
        customFunc(packet)
    }
}

class Debugger0 <: AbstractDebugger {
    static let res: StringBuilder = StringBuilder()
    public Debugger0(connection: XMPPConnection) {
        super(connection)
        super.postInit()
    }
    protected open func log(logMessage: String): Unit {}
    protected open func log(logMessage: String, throwable: Exception): Unit {}
    public open override func outgoingStreamSink(outgoingCharSequence: ToString): Unit {}
    public open override func incomingStreamSink(incomingCharSequence: ToString): Unit {
        res.append(incomingCharSequence.toString())
        res.append("\n")
    }
}

public class Debugger0Factory <: XmppDebuggerFactory {
    Debugger0Factory() {}
    public func create(connection: XMPPConnection): XmppDebugger {
        Debugger0(connection)
    }
}

                   /*
    //                <message xmlns='jabber:client' xml:lang='zh-CN' to='5@xmpp.testserver/2ec11f91-' from='groupbyhlt01@ctserver/9' type='groupchat'><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0'                   id='c1' by='groupbyhlt01@'></stanza-id><addresses xmlns='http://jabber.org/protocol/address'>                  <address type='ofrom' jid='9@xmpp.testserver        '></address></addresses></message>
                   // <message xmlns='jabber:client' xml:lang='zh-CN' to='5@xmpp.testserver/d22b3187-' from='groupbyhlt01@conferen/9' type='groupchat'><body>红红火火</body><stanza-id xmlns='urn:xmpp:sid:0' xmlns:stream='ht' id='50' by='groupbyhlt01@'></stanza-id><addresses xmlns='http://jabber.org/protocol/address' xmlns:stream='ht'><address xmlns:stream='http://etherx.jabber.org/streams' type='ofrom' jid='9@xmpp.testserver'></address></addresses></message>

<message to="5@xmpp.testserver/640712b4-2eb5-450f-a7a5-ef5e6d40234f" type="groupchat" from="groupbyhlt01@conference.xmpp.testserver/9">
  <body>
    红红火火
  </body>
  <stanza-id xmlns="urn:xmpp:sid:0" id="2db83f9b-4561-4e9b-8102-14e1a68ea7b8" by="groupbyhlt01@conference.xmpp.testserver"/>
  <addresses xmlns="http://jabber.org/protocol/address">
    <address type="ofrom" jid="9@xmpp.testserver"/>
  </addresses>
</message>

got packet.toXML() = 
<message xmlns='jabber:client' xml:lang='zh-CN' to='5@xmpp.testserver/39f579cb-7b4b-46ed-af79-4f603b07feed' from='groupbyhlt01@conference.xmpp.testserver' id='7059a619-ab08-41ec-949c-4383d994ee05' type='groupchat'>
    <subject></subject>
</message>

<message xmlns='jabber:client' xml:lang='zh-CN'
    to='5@xmpp.testserver/36254057-be74-4809-b734-dae394a90813'
    from='groupbyhlt01@conference.xmpp.testserver' id='72977ae6-4b2f-4fca-af7d-ded006365d32'
    type='groupchat'>
    <subject></subject>
</message>
<message xmlns='jabber:client' xml:lang='zh-CN' to='5@xmpp.testserver/36254057-be74-4809-b734-dae394a90813' from='groupbyhlt01@conference.xmpp.testserver/9' type='groupchat'>
    <body>红红火火</body>
    <stanza-id xmlns='urn:xmpp:sid:0' id='23712fa0-d355-42df-a14e-715183258403' by='groupbyhlt01@conference.xmpp.testserver'>
    </stanza-id>
    <addresses xmlns='http://jabber.org/protocol/address'>
        <address type='ofrom' jid='9@xmpp.testserver'></address>
    </addresses>
</message>

<message xmlns='jabber:client' xml:lang='zh-CN'
    to='5@xmpp.testserver/640712b4-2eb5-450f-a7a5-ef5e6d40234f'
    from='groupbyhlt01@conference.xmpp.testserver' id='e70e7a67-3b78-49f1-ae08-7027ea1881ff'
    type='groupchat'>
    <subject></subject>
</message>
<message xmlns='jabber:client' xml:lang='zh-CN' to='5@xmpp.testserver/640712b4-2eb5-450f-a7a5-ef5e6d40234f' from='groupbyhlt01@conference.xmpp.testserver/9' type='groupchat'>
    <body>红红火火</body>
    <stanza-id xmlns='urn:xmpp:sid:0' xmlns:stream='http://etherx.jabber.org/streams' id='2db83f9b-4561-4e9b-8102-14e1a68ea7b8' by='groupbyhlt01@conference.xmpp.testserver'>
    </stanza-id>
    <addresses xmlns='http://jabber.org/protocol/address' xmlns:stream='http://etherx.jabber.org/streams'>
        <address xmlns:stream='http://etherx.jabber.org/streams' type='ofrom' jid='9@xmpp.testserver'>
        </address>
    </addresses>
</message>
                   */