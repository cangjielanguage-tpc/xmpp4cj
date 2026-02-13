// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 设置是否将初始可用状态发送到服务器
@Test
func comm_test1(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("6", "123456") // 设置XMPP实体的用户名和密码
        .setSendPresence(false) // 设置是否将初始可用状态发送到服务器
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

// 设置是否将初始可用状态发送到服务器
@Test
func comm_test2(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("7", "123456") // 设置XMPP实体的用户名和密码
        .setSendPresence(false) // 设置是否将初始可用状态发送到服务器
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

// 设置是否将初始可用状态发送到服务器
@Test
func comm_test3(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("6", "123456") // 设置XMPP实体的用户名和密码
        .setSendPresence(true) // 设置是否将初始可用状态发送到服务器
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

// 设置是否将初始可用状态发送到服务器
@Test
func comm_test4(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setUsernameAndPassword("7", "123456") // 设置XMPP实体的用户名和密码
        .setSendPresence(true) // 设置是否将初始可用状态发送到服务器
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