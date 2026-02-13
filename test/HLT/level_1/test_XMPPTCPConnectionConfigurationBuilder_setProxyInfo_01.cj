// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setProxyInfo_01(): Unit {
        let port: UInt16 = 1080 //openfire服务器内部指定的代理端口
        let proxyInfo: ProxyInfo = ProxyInfo.forSocks4Proxy("xmpp.testserver", port, "", "")
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setProxyInfo(proxyInfo) // 设置代理
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
        conn.connect() // 连接
        @Assert(true, conn.isConnected()) // 判断连接状态
        conn.login() // 登录
        @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
        conn.disconnect() // 从服务器断开连接
        @Assert(false, conn.isConnected()) // 判断连接状态
    }
    @TestCase
    func test_setProxyInfo_02(): Unit {
        let port: UInt16 = 1080 //openfire服务器内部指定的代理端口
        let proxyInfo: ProxyInfo = ProxyInfo.forSocks4Proxy("xmpp.testserver", port, "issuser", "1qaz@4321")
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setProxyInfo(proxyInfo) // 设置代理
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        var conn: AbstractXMPPConnection = XMPPTCPConnection(config)
        conn.connect() // 连接
        @Assert(true, conn.isConnected()) // 判断连接状态
        conn.login() // 登录
        @Assert(true, conn.isAuthenticated()) // 判断身份验证状态
        conn.disconnect() // 从服务器断开连接
        @Assert(false, conn.isConnected()) // 判断连接状态
    }
}

