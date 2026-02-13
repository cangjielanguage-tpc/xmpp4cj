// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*
import std.sync.*

// 更新帐号状态
// 使用匿名用户更新账号状态。在线状态更新成离开状态
@Test
func comm_test1(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    conn.login() // 登录
    conn.addSyncStanzaListener(StanzaListener1(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.away)
        .build()
    conn.sendStanza(presence) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn.disconnect() // 从服务器断开连接
}

class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var i = 0

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        println("--1-- v.getMode().toString() = ${v.getMode().toString()}")
                        match (i) {
                            case 0 => @Assert("available", v.getMode().toString())
                            case 1 =>
                                @Assert("away", v.getMode().toString())
                                syncCounter.dec()
                            case _ =>
                                syncCounter.dec()
                                throw Exception()
                        }
                        i++
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
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

// 更新帐号状态
// 使用匿名用户更新账号状态。在线状态更新成空闲状态
@Test
func comm_test2(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    conn.login() // 登录
    conn.addSyncStanzaListener(StanzaListener2(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.chat)
        .build()
    conn.sendStanza(presence) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn.disconnect() // 从服务器断开连接
}

class StanzaListener2 <: StanzaListener {
    var syncCounter: SyncCounter
    var i = 0

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        println("--2-- v.getMode().toString() = ${v.getMode().toString()}")
                        // 判断回调接收的消息
                        match (i) {
                            case 0 => @Assert("available", v.getMode().toString())
                            case 1 =>
                                @Assert("chat", v.getMode().toString())
                                syncCounter.dec()
                            case _ =>
                                syncCounter.dec()
                                throw Exception()
                        }
                        i++
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
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

// 更新帐号状态
// 使用匿名用户更新账号状态。在线状态更新成请勿打扰状态
@Test
func comm_test3(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    conn.login() // 登录
    conn.addSyncStanzaListener(StanzaListener3(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.dnd)
        .build()
    conn.sendStanza(presence) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn.disconnect() // 从服务器断开连接
}

class StanzaListener3 <: StanzaListener {
    var syncCounter: SyncCounter
    var i = 0

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        println("--3-- v.getMode().toString() = ${v.getMode().toString()}")
                        // 判断回调接收的消息
                        match (i) {
                            case 0 => @Assert("available", v.getMode().toString())
                            case 1 =>
                                @Assert("dnd", v.getMode().toString())
                                syncCounter.dec()
                            case _ =>
                                syncCounter.dec()
                                throw Exception()
                        }
                        i++
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
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

// 更新帐号状态
// 使用匿名用户更新账号状态。在线状态更新成长时间离开状态
@Test
func comm_test4(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    conn.login() // 登录
    conn.addSyncStanzaListener(StanzaListener4(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.xa)
        .build()
    conn.sendStanza(presence) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn.disconnect() // 从服务器断开连接
}

class StanzaListener4 <: StanzaListener {
    var syncCounter: SyncCounter
    var i = 0

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        println("--4-- v.getMode().toString() = ${v.getMode().toString()}")
                        // 判断回调接收的消息
                        match (i) {
                            case 0 => @Assert("available", v.getMode().toString())
                            case 1 =>
                                @Assert("xa", v.getMode().toString())
                                syncCounter.dec()
                            case _ =>
                                syncCounter.dec()
                                throw Exception()
                        }
                        i++
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
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

// 更新帐号状态
// 使用匿名用户更新账号状态。在线状态更新成长时间离开状态,长时间离开状态更新为在线，在线状态更新为空闲状态
@Test
func comm_test5(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    conn.login() // 登录
    conn.addSyncStanzaListener(StanzaListener5(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.xa)
        .build()
    conn.sendStanza(presence) // 发送消息
    let presence1: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.available)
        .build()
    conn.sendStanza(presence1) // 发送消息
    let presence2: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.chat)
        .build()
    conn.sendStanza(presence2) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn.disconnect() // 从服务器断开连接
}

class StanzaListener5 <: StanzaListener {
    var syncCounter: SyncCounter
    var i = 0

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Presence) {
            if (let Some(v) <- (packet as Presence)) {
                match (v.getType()) {
                    case PresenceType.available =>
                        // 用户上线
                        println("--5-- v.getMode().toString() = ${v.getMode().toString()}")
                        // 判断回调接收的消息
                        match (i) {
                            case 0 => @Assert("available", v.getMode().toString())
                            case 1 => @Assert("xa", v.getMode().toString())
                            case 2 => @Assert("available", v.getMode().toString())
                            case 3 =>
                                @Assert("chat", v.getMode().toString())
                                syncCounter.dec()
                            case _ =>
                                syncCounter.dec()
                                throw Exception()
                        }
                        i++
                    case PresenceType.unavailable => 
                        // 用户下线
                        ()
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
