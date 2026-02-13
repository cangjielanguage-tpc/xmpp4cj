// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 不同设备登录
@Test
func comm_test1(): Unit {
    let room: Resourcepart = Resourcepart.froms("pc-chat")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("6", "123456") // 设置XMPP实体的用户名和密码
        .setResource(room) // 设置我们从服务器请求的资源
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

// 不同设备登录
@Test
func comm_test2(): Unit {
    let room: Resourcepart = Resourcepart.froms("pc-chat")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("7", "123456") // 设置XMPP实体的用户名和密码
        .setResource(room) // 设置我们从服务器请求的资源
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

// 不同设备登录
@Test
func comm_test3(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("6", "123456") // 设置XMPP实体的用户名和密码
        .setResource("phone-chat") // 设置我们从服务器请求的资源
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

// 不同设备登录
@Test
func comm_test4(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("7", "123456") // 设置XMPP实体的用户名和密码
        .setResource("phone-chat") // 设置我们从服务器请求的资源
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

// 向同一账户不同设备发送消息,分别登录Android、pc、ios三个设备，并且分别向不同的设备发送消息
// 用户12向用户10登录的不同设备发送消息
@Test
func comm_test5(): Unit {
    let syncCounter: SyncCounter = SyncCounter(3)
    // 接收消息 - pc
    let room1: Resourcepart = Resourcepart.froms("pc-chat")
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setResource(room1) // 设置我们从服务器请求的资源
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login("10", "123456") // 登录
    conn1.addSyncStanzaListener(StanzaListener1(syncCounter, conn1), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 接收消息 - android
    let room2: Resourcepart = Resourcepart.froms("android-chat")
    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setResource(room2) // 设置我们从服务器请求的资源
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
    conn2.connect() // 连接
    conn2.login("10", "123456") // 登录
    conn2.addSyncStanzaListener(StanzaListener2(syncCounter, conn2), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 接收消息 -ios
    let room3: Resourcepart = Resourcepart.froms("ios-chat")
    let config3: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setResource(room3) // 设置我们从服务器请求的资源
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn3: XMPPTCPConnection = XMPPTCPConnection(config3)
    conn3.connect() // 连接
    conn3.login("10", "123456") // 登录
    conn3.addSyncStanzaListener(StanzaListener3(syncCounter, conn3), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    // 发送消息
    let config4: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn4: XMPPTCPConnection = XMPPTCPConnection(config4)
    conn4.connect() // 连接
    conn4.login("12", "123456") // 登录

    // 发送消息给pc设备
    let entityBareJid1: EntityBareJid = JidCreate.entityBareFrom("10@xmpp.testserver")
    let fullJid1: FullJid = JidCreate.fullFrom(entityBareJid1, room1)
    let message1: Message = MessageBuilder
        .buildMessage()
        .to(fullJid1) // 设置消息的接收方地址
        .ofType(MessageType.chat) // 设置消息类型
        .setBody("message: 12@xmpp.testserver to 10@xmpp.testserver pc-chat") // 设置消息正文
        .build()
    conn4.sendStanza(message1) // 发送消息

    // 发送消息给android设备
    let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("10@xmpp.testserver")
    let fullJid2: FullJid = JidCreate.fullFrom(entityBareJid2, room2)
    let message2: Message = MessageBuilder
        .buildMessage()
        .to(fullJid2) // 设置消息的接收方地址
        .ofType(MessageType.chat) // 设置消息类型
        .setBody("message: 12@xmpp.testserver to 10@xmpp.testserver android-chat") // 设置消息正文
        .build()
    conn4.sendStanza(message2) // 发送消息

    // 发送消息给ios设备
    let entityBareJid3: EntityBareJid = JidCreate.entityBareFrom("10@xmpp.testserver")
    let fullJid3: FullJid = JidCreate.fullFrom(entityBareJid3, room3)
    let message3: Message = MessageBuilder
        .buildMessage()
        .to(fullJid3) // 设置消息的接收方地址
        .ofType(MessageType.chat) // 设置消息类型
        .setBody("message: 12@xmpp.testserver to 10@xmpp.testserver ios-chat") // 设置消息正文
        .build()
    conn4.sendStanza(message3) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
    conn3.disconnect() // 从服务器断开连接
    conn4.disconnect() // 从服务器断开连接
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
                let user = conn.getUser()
                // let user1  = user?.asEntityBareJid()
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
                                    println("pc-chat,body.getOrThrow() = ${body.getOrThrow()}")
                                    // 判断回调接收的消息
                                    @Assert("message: 12@xmpp.testserver to 10@xmpp.testserver pc-chat", body.getOrThrow())
                                    syncCounter.dec()
                                } else {
                                    // 消息是发送给其他用户的，可能是转发等情况
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
                let user = conn.getUser()
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
                                    println("android-chat,body.getOrThrow() = ${body.getOrThrow()}")
                                    // 判断回调接收的消息
                                    @Assert("message: 12@xmpp.testserver to 10@xmpp.testserver android-chat", body.getOrThrow())
                                    syncCounter.dec()
                                } else {
                                    // 消息是发送给其他用户的，可能是转发等情况
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

class StanzaListener3 <: StanzaListener {
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
                let user = conn.getUser()
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
                                    println("ios-chat,body.getOrThrow() = ${body.getOrThrow()}")
                                    // 判断回调接收的消息
                                    @Assert("message: 12@xmpp.testserver to 10@xmpp.testserver ios-chat", body.getOrThrow())
                                    syncCounter.dec()
                                } else {
                                    // 消息是发送给其他用户的，可能是转发等情况
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

