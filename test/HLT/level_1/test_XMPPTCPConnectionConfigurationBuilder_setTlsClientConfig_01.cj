// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import stdx.net.*
import stdx.net.tls.*

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setTlsClientConfig_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        var tlsConfig=TlsClientConfig()
        tlsConfig.verifyMode=CertificateVerifyMode.TrustAll
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setTlsClientConfig(tlsConfig)
        .performSaslAnonymousAuthentication()
        var configreationtls=configBuilder.build()
        let connection = XMPPTCPConnection(configreationtls)
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        connection.disconnect()
        var realTlsClientConfig=configreationtls.getTlsClientConfig()
        @Assert(realTlsClientConfig.isNone(),false)
    }

}

