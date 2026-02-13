// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 验证错误消息
@Test
func comm_test1(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    // 发送消息
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        // .enableDefaultDebugger() // 启用默认调试器
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    conn2.connect() // 连接
    conn2.login("10", "123456") // 登录
    conn2.addSyncStanzaListener(StanzaListener2(syncCounter, conn2), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 发送群聊消息
    let entityBareJid3: EntityBareJid = JidCreate.entityBareFrom("group1@conference.xmpp.testserver")
    let message2: Message = MessageBuilder
        .buildMessage()
        .to(entityBareJid3) // 设置消息的接收方地址
        .froms(conn2.getUser().getOrThrow())
        .ofType(MessageType.groupchat) // 设置消息类型
        .setBody("message: 21@xmpp.testserver") // 设置消息正文
        .build()
    conn2.sendStanza(message2) // 发送消息

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn2.disconnect() // 从服务器断开连接
}

class StanzaListener2 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    var i  = 0

    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Message) {
            if (let Some(v) <- (packet as Message)) {
                let body = v.getBody()
                let from = v.getFrom()
                let to = v.getTo()
                let user = conn.getUser()?.asEntityBareJid()
                match(v.getType()){
                    case Some(MessageType.normal) =>
                        // 默认普通文本消息
                        ()
                    case Some(MessageType.chat) =>
                        // 较短的文本消息
                        match((user, to)){
                            case (None, None) => throw Exception()
                            case (Some(v), Some(w)) => 
                                if (v == w) {
                                    // 消息是发送给自己的，显示在聊天窗口
                                } else {
                                    // 消息是发送给其他用户的，可能是转发代理等情况
                                }
                            case _ => throw Exception()
                        }
                    case Some(MessageType.groupchat) =>
                        // 群聊消息
                        ()
                    case Some(MessageType.headline) =>
                        // 通知消息
                        ()
                    case Some(MessageType.error) =>
                        // 错误消息
                        i++
                        println("--2-- i= ${i}, v.getBody() = ${v.getBody()}, from = ${from}, to = ${to}")
                        @Assert(true, from.isSome())
                        @Assert(true, to.isSome())
                    case _ => throw Exception()
                }
            }
        }
        if(i == 1){
            syncCounter.dec()
        }
    }
}
