// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户1，判断身份验证状态
@Test
func comm_test1(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("1", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户2，判断身份验证状态
@Test
func comm_test2(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("2", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户3，判断身份验证状态
@Test
func comm_test3(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("3", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户4，判断身份验证状态
@Test
func comm_test4(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("4", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户5，判断身份验证状态
@Test
func comm_test5(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("5", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户6，判断身份验证状态
@Test
func comm_test6(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("6", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户7，判断身份验证状态
@Test
func comm_test7(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("7", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户8，判断身份验证状态
@Test
func comm_test8(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("8", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户9，判断身份验证状态
@Test
func comm_test9(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("9", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户10，判断身份验证状态
@Test
func comm_test10(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("10", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户11，判断身份验证状态
@Test
func comm_test11(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("11", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户12，判断身份验证状态
@Test
func comm_test12(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("12", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户13，判断身份验证状态
@Test
func comm_test13(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("13", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 加密连接，setHost(String), setPort(UInt16) 连接，并登录用户14，判断身份验证状态
@Test
func comm_test14(): Unit {
    let port: UInt16 = 5222
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(port) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("14", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}
