// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.sasl.*
import cangjie_tpc::xmpp4cj.feature.*
import std.time.*
import stdx.net.*
import stdx.net.tls.*
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_performSaslExternalAuthentication_01(): Unit {
        let id: EntityBareJid = JidCreate.entityBareFrom("1@xmpp.testserver")
        var tlsConfig=TlsClientConfig()
        tlsConfig.verifyMode=CertificateVerifyMode.TrustAll
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setUsernameAndPassword("test2", "123456")
        let e=@AssertThrows[IllegalArgumentException](config.performSaslExternalAuthentication(TlsClientConfig()))
        @Assert(e.toString(),"IllegalArgumentException: SASL EXTERNAL is not registered")
    }
    @TestCase
    func test_performSaslExternalAuthentication_02(): Unit {
        XmppConfiguration.DEBUG = true
        var tlsConfig=TlsClientConfig()
        tlsConfig.verifyMode=CertificateVerifyMode.TrustAll
        let configbuilder = XMPPTCPConnectionConfiguration.builder()
        configbuilder.setCallbackHandler({a => ()})
        configbuilder.setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        configbuilder.setXmppDomain(XmppTestServerHostName)
        configbuilder.setTlsClientConfig(tlsConfig)
        configbuilder.setSocketFactory(SocketFactory.DEFAULT)
        let mechanism = SASLMechanismExternal()
        SASLAuthentication.registerSASLMechanism(mechanism)
        configbuilder.performSaslExternalAuthentication(tlsConfig)
        let config=configbuilder.build()
        let conn= XMPPTCPConnection(config)
        conn.connect() 
        let e:XmppSaslException=@AssertThrows[XmppSaslException](conn.login("1","123456"))
        @Assert(e.toString().contains("XmppSaslException: No supported and enabled SASL Mechanism provided by server"),true)
        conn.disconnect()
    }
}
class SASLMechanismExternal <: SASLMechanism {
    protected func authenticateInternal(cbh: ?CallbackHandler): Unit {
        throw Exception()
    }
    protected func getAuthenticationText(): ?Array<Byte> {
        throw Exception()
    }
    public func getName(): String {
        return SASLMechanism.EXTERNAL
    }
    public func getPriority(): Int {
        return 0
    }
    protected func checkIfSuccessfulOrThrow(): Unit {
    }
    protected func newInstance(): SASLMechanism {
        throw Exception()
    }
}
