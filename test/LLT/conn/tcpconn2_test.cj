// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 未加密连接，setHost(String) 连接，并登录用户1，判断身份验证状态
@Test
func comm_test1(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("1", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户2，判断身份验证状态
@Test
func comm_test2(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("2", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户3，判断身份验证状态
@Test
func comm_test3(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("3", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户4，判断身份验证状态
@Test
func comm_test4(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("4", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户5，判断身份验证状态
@Test
func comm_test5(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("5", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户6，判断身份验证状态
@Test
func comm_test6(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("6", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户7，判断身份验证状态
@Test
func comm_test7(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("7", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户8，判断身份验证状态
@Test
func comm_test8(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("8", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户9，判断身份验证状态
@Test
func comm_test9(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("9", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户10，判断身份验证状态
@Test
func comm_test10(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("10", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户11，判断身份验证状态
@Test
func comm_test11(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("11", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户12，判断身份验证状态
@Test
func comm_test12(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("12", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户13，判断身份验证状态
@Test
func comm_test13(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("13", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，并登录用户14，判断身份验证状态
@Test
func comm_test14(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("14", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户1，判断身份验证状态
@Test
func comm_test15(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("1", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户2，判断身份验证状态
@Test
func comm_test16(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("2", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户3，判断身份验证状态
@Test
func comm_test17(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("3", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户4，判断身份验证状态
@Test
func comm_test18(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("4", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户5，判断身份验证状态
@Test
func comm_test19(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("5", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户6，判断身份验证状态
@Test
func comm_test20(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("6", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户7，判断身份验证状态
@Test
func comm_test21(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("7", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户8，判断身份验证状态
@Test
func comm_test22(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("8", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户9，判断身份验证状态
@Test
func comm_test23(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("9", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户10，判断身份验证状态
@Test
func comm_test24(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("10", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户11，判断身份验证状态
@Test
func comm_test25(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("11", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户12，判断身份验证状态
@Test
func comm_test26(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("12", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户13，判断身份验证状态
@Test
func comm_test27(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("13", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setUsernameAndPassword(String, String)设置登录用户信息，并登录用户14，判断身份验证状态
@Test
func comm_test28(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setUsernameAndPassword("14", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户1，判断身份验证状态
@Test
func comm_test29(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("1@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户2，判断身份验证状态
@Test
func comm_test30(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("2@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户3，判断身份验证状态
@Test
func comm_test31(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("3@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户4，判断身份验证状态
@Test
func comm_test32(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("4@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户5，判断身份验证状态
@Test
func comm_test33(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("5@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户6，判断身份验证状态
@Test
func comm_test34(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("6@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户7，判断身份验证状态
@Test
func comm_test35(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("7@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户8，判断身份验证状态
@Test
func comm_test36(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("8@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户9，判断身份验证状态
@Test
func comm_test37(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("9@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户10，判断身份验证状态
@Test
func comm_test38(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("10@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户11，判断身份验证状态
@Test
func comm_test39(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("11@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户12，判断身份验证状态
@Test
func comm_test40(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("12@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户13，判断身份验证状态
@Test
func comm_test41(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("13@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(String, String)设置登录用户信息，并登录用户14，判断身份验证状态
@Test
func comm_test42(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword("14@xmpp.testserver", "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户1，判断身份验证状态
@Test
func comm_test43(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("1@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户2，判断身份验证状态
@Test
func comm_test44(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("2@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户3，判断身份验证状态
@Test
func comm_test45(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("3@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户4，判断身份验证状态
@Test
func comm_test46(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("4@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户5，判断身份验证状态
@Test
func comm_test47(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("5@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户6，判断身份验证状态
@Test
func comm_test48(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("6@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户7，判断身份验证状态
@Test
func comm_test49(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("7@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户8，判断身份验证状态
@Test
func comm_test50(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("8@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户9，判断身份验证状态
@Test
func comm_test51(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("9@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户10，判断身份验证状态
@Test
func comm_test52(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("10@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户11，判断身份验证状态
@Test
func comm_test53(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("11@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户12，判断身份验证状态
@Test
func comm_test54(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("12@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户13，判断身份验证状态
@Test
func comm_test55(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("13@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}

// 未加密连接，setHost(String) 连接，通过setXmppAddressAndPassword(EntityBareJid, String)设置登录用户信息，并登录用户14，判断身份验证状态
@Test
func comm_test56(): Unit {
    let id: EntityBareJid = JidCreate.entityBareFrom("14@xmpp.testserver")
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setXmppAddressAndPassword(id, "123456") // 设置XMPP实体的用户名和密码
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login() // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
}
