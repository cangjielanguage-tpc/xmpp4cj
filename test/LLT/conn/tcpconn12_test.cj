// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

extend XMPPTCPConnection {
    static func create(jid: String, password: String): XMPPTCPConnection {
        let builder = XMPPTCPConnectionConfiguration.builder()
        builder.setXmppAddressAndPassword(jid, password).setTlsClientConfig(TLS_TRUST_ALL)
        XMPPTCPConnection(builder.build())
    }
    static func create(username: String, password: String, domain: String): XMPPTCPConnection {
        let builder = XMPPTCPConnectionConfiguration.builder()
        builder
            .setUsernameAndPassword(username, password)
            .setXmppDomain(JidCreate.domainBareFrom(domain))
            .setTlsClientConfig(TLS_TRUST_ALL)
        XMPPTCPConnection(builder.build())
    }
}

// 普通链接，不设置config
@Test
func comm_test1(): Unit {
    var conn: XMPPTCPConnection = XMPPTCPConnection.create("6@xmpp.testserver", "123456")
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 普通链接，不设置config
@Test
func comm_test2(): Unit {
    var conn: AbstractXMPPConnection = XMPPTCPConnection.create("7@xmpp.testserver", "123456")
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 普通链接，不设置config
@Test
func comm_test3(): Unit {
    var conn: XMPPTCPConnection = XMPPTCPConnection.create("6", "123456", "xmpp.testserver")
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 普通链接，不设置config
@Test
func comm_test4(): Unit {
    var conn: AbstractXMPPConnection = XMPPTCPConnection.create("7", "123456", "xmpp.testserver")
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 普通链接，不设置config
@Test
func comm_test5(): Unit {
    var conn: XMPPTCPConnection = XMPPTCPConnection.create("6@xmpp.testserver", "123456")
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    @Assert(false, conn.isAnonymous())
    @Assert("SCRAM-SHA-1", conn.getUsedSaslMechansism().getOrThrow())
    conn.getUsedSaslMechansism()
    conn.setFromMode(XMPPConnectionFromMode.UNCHANGED)
    @Assert(XMPPConnectionFromMode.UNCHANGED, conn.getFromMode())
    conn.setFromMode(XMPPConnectionFromMode.OMITTED)
    @Assert(XMPPConnectionFromMode.OMITTED, conn.getFromMode())
    conn.setFromMode(XMPPConnectionFromMode.USER)
    @Assert(XMPPConnectionFromMode.USER, conn.getFromMode())
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 普通链接，不设置config
@Test
func comm_test6(): Unit {
    var conn: AbstractXMPPConnection = XMPPTCPConnection.create("7@xmpp.testserver", "123456")
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}
