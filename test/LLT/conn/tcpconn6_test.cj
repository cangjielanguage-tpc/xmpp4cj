// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

/* TODO */

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 未加密连接，设置 DNSSEC 模式，不进行任何 DNSSEC 认证或 DANE 验证，setHost(String) 连接和断开连接,并判断连接状态
@Test
func comm_test1(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setDnssecMode(DnssecMode.disabled) // 设置 DNSSEC 模式
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isSecureConnection()) // 检查连接是否为安全连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("14", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// 未加密连接，设置 DNSSEC 模式，要求所有 DNS 信息都需通过 DNSSEC 认证，setHost(String) 连接和断开连接,并判断连接状态
@Test
func comm_test2(): Unit {
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(5222) // 设置端口号
        .setDnssecMode(DnssecMode.needsDnssec) // 设置 DNSSEC 模式
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
    conn.connect() // 连接
    @Assert(true, conn.isConnected()) // 判断连接状态
    @Assert(false, conn.isSecureConnection()) // 检查连接是否为安全连接
    @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
    conn.login("14", "123456") // 登录
    @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
    conn.disconnect() // 从服务器断开连接
    @Assert(false, conn.isConnected()) // 判断连接状态
}

// // 未加密连接，设置 DNSSEC 模式，要求所有 DNS 信息都需通过 DNSSEC 认证，并要求使用 DANE 验证 XMPP 服务的 TLS 证书，setHost(String) 连接和断开连接,并判断连接状态
// @Test
// func comm_test3(): Unit {
//     let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
//         .builder()
//         .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
//         .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
//         .setPort(5222) // 设置端口号
//         .setDnssecMode(DnssecMode.needsDnssecAndDane) // 设置 DNSSEC 模式
//         .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
//         .build()
//     var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
//     conn.connect() // 连接
//     @Assert(true, conn.isConnected()) // 判断连接状态
//     @Assert(false, conn.isSecureConnection()) // 检查连接是否为安全连接
//     @Assert(false, conn.isAuthenticated()) // 判断身份验证状态
//     conn.login("14", "123456") // 登录
//     @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
//     conn.disconnect() // 从服务器断开连接
//     @Assert(false, conn.isConnected()) // 判断连接状态
// }