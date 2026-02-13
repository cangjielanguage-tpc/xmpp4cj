// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

/* TODO */
// 手动用例,需要后台推送

// 用户11接收后台推送消息
@Test
func comm_test1(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    // 接收消息
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    conn.login("11", "123456") // 登录
    conn.addSyncStanzaListener(StanzaListener1(syncCounter, conn), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn.disconnect() // 从服务器断开连接
}

class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection

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
                        println("body.getOrThrow() = ${body.getOrThrow()}")
                        syncCounter.dec()
                    case Some(MessageType.error) =>
                        // 错误消息
                        ()
                    case _ => throw Exception()
                }
            }
        }
    }
}