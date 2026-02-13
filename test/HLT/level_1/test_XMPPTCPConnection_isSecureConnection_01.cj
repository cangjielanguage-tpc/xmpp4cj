// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*
import stdx.net.tls.*
@Test
public class TestXMPPTCPConnection{
    @TestCase
    func test_isSecureConnection_01(): Unit {
        var tlsConfig=TlsClientConfig()
        tlsConfig.verifyMode=CertificateVerifyMode.TrustAll
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setTlsClientConfig(tlsConfig)
        .setXmppAddressAndPassword("test2@xmpp.testserver", "123456")
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        var iq01=ElementRegister()
        connection.sendStanza(iq01)
        connection.login()
        @Assert(connection.isSecureConnection(),true)
        var iq02=ElementUnRegister()
        connection.sendStanza(iq02)
        connection.disconnect()
    }
    @TestCase
    func test_isSecureConnection_02(): Unit {
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication() // 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        var connection: AbstractXMPPConnection = XMPPTCPConnection(config)
        connection.connect()
        connection.login()
        @Assert(connection.isSecureConnection(),false)
        connection.disconnect()
    }
}
//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test2</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
