// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

/* TODO */
// 需要本地设置代理

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 代理配置 - Socks4, 未加密
@Test
func comm_test1(): Unit {
    let port: UInt16 = 1080
    let proxyInfo: ProxyInfo = ProxyInfo.forSocks4Proxy(XmppTestServerHostName, port, "issuser", "1qaz@4321")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("6", "123456") // 设置XMPP实体的用户名和密码
        .setProxyInfo(proxyInfo) // 设置代理
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isSecureConnection()) // 检查连接是否为安全连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 代理配置 - Socks4, 加密
@Test
func comm_test2(): Unit {
    let port: UInt16 = 1080
    let proxyInfo: ProxyInfo = ProxyInfo.forSocks4Proxy(XmppTestServerHostName, port, "issuser", "1qaz@4321")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("7", "123456") // 设置XMPP实体的用户名和密码
        .setProxyInfo(proxyInfo) // 设置代理
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 代理配置 - Socks4, 消息发送，未加密
@Test
func comm_test3(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    // 接收消息
    let port1: UInt16 = 1080
    let proxyInfo1: ProxyInfo = ProxyInfo.forSocks4Proxy(XmppTestServerHostName, port1, "issuser", "1qaz@4321")
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setProxyInfo(proxyInfo1) // 设置代理
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login("11", "123456") // 登录
    conn1.addSyncStanzaListener(StanzaListener1(syncCounter, conn1), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 发送消息
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setProxyInfo(proxyInfo1) // 设置代理
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    conn2.connect() // 连接
    conn2.login("12", "123456") // 登录
    let entityBareJid: EntityBareJid = JidCreate.entityBareFrom("11@xmpp.testserver")
    let message: Message = MessageBuilder
        .buildMessage()
        .to(entityBareJid) // 设置消息的接收方地址
        .ofType(MessageType.chat) // 设置消息类型
        .setBody("message: 12@xmpp.testserver to 11@xmpp.testserver") // 设置消息正文
        .build()
    conn2.sendStanza(message) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 10)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
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
                                    println("body.getOrThrow() = ${body.getOrThrow()}")
                                    // 判断回调接收的消息
                                    @Assert("message: 12@xmpp.testserver to 11@xmpp.testserver", body.getOrThrow())
                                    syncCounter.dec()
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
                        ()
                    case _ => throw Exception()
                }
            }
        }
    }
}

// 代理配置 - Socks4, 消息发送，加密
@Test
func comm_test4(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    // 接收消息
    let port1: UInt16 = 1080
    let proxyInfo1: ProxyInfo = ProxyInfo.forSocks4Proxy(XmppTestServerHostName, port1, "issuser", "1qaz@4321")
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setProxyInfo(proxyInfo1) // 设置代理
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login("10", "123456") // 登录
    conn1.addSyncStanzaListener(StanzaListener2(syncCounter, conn1), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 发送消息
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setProxyInfo(proxyInfo1) // 设置代理
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    conn2.connect() // 连接
    conn2.login("12", "123456") // 登录
    let entityBareJid: EntityBareJid = JidCreate.entityBareFrom("10@xmpp.testserver")
    let message: Message = MessageBuilder
        .buildMessage()
        .to(entityBareJid) // 设置消息的接收方地址
        .ofType(MessageType.chat) // 设置消息类型
        .setBody("message: 12@xmpp.testserver to 10@xmpp.testserver") // 设置消息正文
        .build()
    conn2.sendStanza(message) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 10)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
}

class StanzaListener2 <: StanzaListener {
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
                                    println("body.getOrThrow() = ${body.getOrThrow()}")
                                    // 判断回调接收的消息
                                    @Assert("message: 12@xmpp.testserver to 10@xmpp.testserver", body.getOrThrow())
                                    syncCounter.dec()
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
                        ()
                    case _ => throw Exception()
                }
            }
        }
    }
}
