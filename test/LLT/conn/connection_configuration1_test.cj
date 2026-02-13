// DEPENDENCE: ../z_test.cj ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main

import std.net.*

@Test
public class ConnectionConfiguration1Test {
    @TestCase
    public func test1() {
        // 最小连接配置。域 + 主机名 + 端口号
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .build()
        @Assert("30s", config.getConnectTimeout().toString()) // 超时时间
        @Assert("xmpp.testserver", config.getHost().getOrThrow()) // 主机
        @Assert("xmpp.testserver", config.getHostString().toString()) // 主机
        @Assert(None, config.getHostAddress()) // Address
        @Assert("", config.getPassword()??"") // 密码
        @Assert("zh-CN", config.getXmlLang().getOrThrow()) // 语言
        @Assert("zh_CN", config.getLanguage().getOrThrow()) // 语言
        @Assert("disabled", config.getDnssecMode().toString()) // DNS
        @Assert("", config.getUsername()??"") // 用户名
        @Assert("5222", config.getPort().toString()) // 端口
        @Assert(None, config.getAuthzid()) // Authzid
        @Assert("required", config.getSecurityMode().toString()) // 安全模式
        @Assert(true, config.isSendPresence()) // 如果在重新连接登录时应该发送可用状态
        @Assert(false, config.isCompressionEnabled()) // 如果连接将使用流压缩
    }

    @TestCase
    public func test2(): Unit {
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .setCompressionEnabled(true) // 压缩
            .build()
        @Assert(true, config.isCompressionEnabled()) // 如果连接将使用流压缩
    }

    @TestCase
    public func test3(): Unit {
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .setSendPresence(false) // 如果在重新连接登录时应该发送可用状态
            .build()
        @Assert(false, config.isSendPresence()) // 如果连接将使用流压缩
    }

    @TestCase
    public func test4(): Unit {
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setUsernameAndPassword("1", "123456") // 设置XMPP实体的用户名和密码
            .setPort(5222) // 设置端口号
            .build()
        @Assert("123456", config.getPassword().getOrThrow()) // 密码
        @Assert("1", config.getUsername().getOrThrow()) // 用户名
    }

    @TestCase
    public func test5(): Unit {
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setConnectTimeout(Duration.second * 10) // 超时时间
            .setPort(5222) // 设置端口号
            .build()
        @Assert("10s", config.getConnectTimeout().toString()) // 超时时间
    }

    @TestCase
    public func test6(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHostAddress(iplist[0])// 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .build()
        @Assert(true, config.getHostAddress().isSome()) // Address
    }

    @TestCase
    public func test7(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHostAddress(iplist[0])// 设置提供XMPP服务的主机的名称
            .setLanguage("zh-cn")// 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .build()
        @Assert("zh-cn", config.getLanguage().getOrThrow()) // Language
    }
}
