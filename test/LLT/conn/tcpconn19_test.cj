// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 匿名用户上线下线 - 手动发送下线消息下线
@Test
func comm_test1(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login() // 登录
    conn1.addSyncStanzaListener(StanzaListener1(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    
    let presence1: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .ofType(PresenceType.unavailable)
        .build()
    conn1.sendStanza(presence1) // 发送消息

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
}

class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                // 判断回调接收的消息
                match(v.getType()){
                    case PresenceType.available => 
                        // 用户上线
                        println("--1-- PresenceType.available v.isAvailable() = ${v.isAvailable()}")
                        @Assert(true, v.isAvailable())
                    case PresenceType.unavailable => 
                        // 用户下线
                        println("--1-- PresenceType.unavailable v.isAvailable() = ${v.isAvailable()}")
                        @Assert(false, v.isAvailable())
                        syncCounter.dec()
                    case PresenceType.subscribe => 
                        // 收到添加好友请求
                        ()
                    case PresenceType.subscribed => 
                        // 添加好友请求通过
                        ()
                    case PresenceType.unsubscribe => 
                        // 收到删除好友请求
                        ()
                    case PresenceType.unsubscribed => 
                        // 删除好友请求通过
                        ()
                    case _ => ()
                }
            }
        }
    }
}

// 匿名用户上线下线 - 断开连接自动发送下线消息
@Test
func comm_test2(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login() // 登录
    conn1.addSyncStanzaListener(StanzaListener2(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    
    conn1.disconnect()

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
}

class StanzaListener2 <: StanzaListener {
    var syncCounter: SyncCounter

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                // 判断回调接收的消息
                match(v.getType()){
                    case PresenceType.available => 
                        // 用户上线
                        println("--2-- PresenceType.available v.isAvailable() = ${v.isAvailable()}")
                        @Assert(true, v.isAvailable())
                    case PresenceType.unavailable => 
                        // 用户下线
                        println("--2-- PresenceType.unavailable v.isAvailable() = ${v.isAvailable()}")
                        @Assert(false, v.isAvailable())
                        syncCounter.dec()
                    case PresenceType.subscribe => 
                        // 收到添加好友请求
                        ()
                    case PresenceType.subscribed => 
                        // 添加好友请求通过
                        ()
                    case PresenceType.unsubscribe => 
                        // 收到删除好友请求
                        ()
                    case PresenceType.unsubscribed => 
                        // 删除好友请求通过
                        ()
                    case _ => ()
                }
            }
        }
    }
}
