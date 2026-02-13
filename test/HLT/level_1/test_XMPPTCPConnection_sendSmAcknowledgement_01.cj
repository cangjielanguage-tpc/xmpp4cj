// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXMPPTCPConnection{
    @TestCase
    func test_sendSmAcknowledgement_01(): Unit {
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
            .setPort(5222) // 设置端口号
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        var connection: XMPPTCPConnection = XMPPTCPConnection(config)
        let e:StreamManagementNotEnabledException=@AssertThrows[StreamManagementNotEnabledException](connection.sendSmAcknowledgement())
        @Assert(e.toString().contains("StreamManagementNotEnabledException"),true)
    }
}
