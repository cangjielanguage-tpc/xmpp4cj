// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 未加密连接，setHost(String) 连接和断开连接,并判断连接状态
@Test
func comm_test1(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 未加密连接，setHostAddress(IPAddress) 连接和断开连接,并判断连接状态
@Test
func comm_test2(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)// 设置XMPP域
        .setHostAddress(iplist[0])// 设置提供XMPP服务的主机的名称
        .setPort(5222)// 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)// 设置建立连接时使用的TLS安全模式
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 加密连接，setHost(String) 连接和断开连接,并判断连接状态
@Test
func comm_test3(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 加密连接，setHostAddress(IPAddress) 连接和断开连接,并判断连接状态
@Test
func comm_test4(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)// 设置XMPP域
        .setHostAddress(iplist[0])// 设置提供XMPP服务的主机的名称
        .setPort(5222)// 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required)// 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 默认连接，setHost(String) 连接和断开连接,并判断连接状态
@Test
func comm_test5(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 默认连接，setHostAddress(IPAddress) 连接和断开连接,并判断连接状态
@Test
func comm_test6(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)// 设置XMPP域
        .setHostAddress(iplist[0])// 设置提供XMPP服务的主机的名称
        .setPort(5222)// 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required)// 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 默认连接，setHost(String) 连接和断开连接,并判断连接状态
@Test
func comm_test7(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 默认连接，setHostAddress(IPAddress) 连接和断开连接,并判断连接状态
@Test
func comm_test8(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)// 设置XMPP域
        .setHostAddress(iplist[0])// 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(true, conn.isSecureConnection()) // 检查连接是否为安全连接
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

