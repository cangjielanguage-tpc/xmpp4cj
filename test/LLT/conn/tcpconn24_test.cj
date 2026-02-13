// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 添加好友,并同意添加，然后在删除，在同意删除
@Test
func comm_test1(): Unit {
    let syncCounter: SyncCounter = SyncCounter(2)
    // 接收消息
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login("12", "123456") // 登录
    conn1.addSyncStanzaListener(StanzaListener1(syncCounter, conn1), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 发送消息
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    conn2.connect() // 连接
    conn2.login("10", "123456") // 登录
    conn2.addSyncStanzaListener(StanzaListener2(syncCounter, conn2), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    let presence2: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("add 12")
        .ofType(PresenceType.subscribe)
        .to(conn1.getUser().getOrThrow())
        .froms(conn2.getUser().getOrThrow())
        .build()
    conn2.sendStanza(presence2) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 5)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
}

class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    var i = 0

    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        ()
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
                    case PresenceType.subscribe => 
                        // 收到添加好友请求
                        i++
                        // 同意添加好友
                        let presence2: Presence = PresenceBuilder
                            .buildPresence()
                            .setStatus("add 12")
                            .ofType(PresenceType.subscribed)
                            .to(v.getFrom().getOrThrow())
                            .froms(v.getTo().getOrThrow())
                            .build()
                        conn.sendStanza(presence2) // 发送消息
                        println("--1 PresenceType.subscribe -- i = ${i}")
                        @Assert(1, i)
                    case PresenceType.subscribed => 
                        // 添加好友请求通过
                        ()
                    case PresenceType.unsubscribe => 
                        // 收到删除好友请求
                        i++
                        // 同意删除好友
                        let presence2: Presence = PresenceBuilder
                            .buildPresence()
                            .setStatus("del 12")
                            .ofType(PresenceType.unsubscribed)
                            .to(v.getFrom().getOrThrow())
                            .froms(v.getTo().getOrThrow())
                            .build()
                        conn.sendStanza(presence2) // 发送消息
                        println("--1 PresenceType.unsubscribe-- i = ${i}")
                        @Assert(2, i)
                    case PresenceType.unsubscribed => 
                        // 删除好友请求通过
                        ()
                    case _ => ()
                }
            }
        }
        if(i == 2){
            syncCounter.dec()
        }
    }
}

class StanzaListener2 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    var i = 0

    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        ()
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
                    case PresenceType.subscribe => 
                        // 收到添加好友请求
                        ()
                    case PresenceType.subscribed => 
                        // 添加好友请求通过
                        i++
                        // 删除好友
                        let presence2: Presence = PresenceBuilder
                            .buildPresence()
                            .setStatus("del 12")
                            .ofType(PresenceType.unsubscribe)
                            .to(v.getFrom().getOrThrow())
                            .froms(v.getTo().getOrThrow())
                            .build()
                        conn.sendStanza(presence2) // 发送消息
                        println("--2 PresenceType.subscribed-- i = ${i}")
                        @Assert(1, i)
                    case PresenceType.unsubscribe => 
                        // 收到删除好友请求
                        ()
                    case PresenceType.unsubscribed => 
                        // 删除好友请求通过
                        i++
                        println("--2 PresenceType.unsubscribed-- i = ${i}")
                        @Assert(2, i)
                    case _ => ()
                }
            }
        }
        if(i == 2){
            syncCounter.dec()
        }
    }
}

