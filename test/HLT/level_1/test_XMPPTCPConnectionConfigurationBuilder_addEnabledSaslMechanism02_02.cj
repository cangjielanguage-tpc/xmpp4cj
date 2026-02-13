// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.sasl.*
import std.time.*
import stdx.net.*
import stdx.net.tls.*
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_test_addEnabledSaslMechanism02_01(): Unit {
        let saslMechanismStrs=["NTLM"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString().contains("IllegalArgumentException: SASL NTLM is not available. Consider registering it with Xmpp"), true)
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_02(): Unit {
        let saslMechanismStrs=["CRAM-MD5"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalStateException=@AssertThrows[IllegalStateException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString(),"IllegalStateException: The enabled SASL mechanisms are sealed, you can not add new ones")
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_03(): Unit {
         let saslMechanismStrs=["PLAIN"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString().contains("IllegalArgumentException: SASL PLAIN is not available. Consider registering it with Xmpp"), true)
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_04(): Unit {
         let saslMechanismStrs=["JIVE-SHAREDSECRET"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString().contains("IllegalArgumentException: SASL JIVE-SHAREDSECRET is not available. Consider registering it with Xmpp"), true)
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_05(): Unit {
        let saslMechanismStrs=["GSSAPI"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString().contains("IllegalArgumentException: SASL GSSAPI is not available. Consider registering it with Xmpp"), true)
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_06(): Unit {
        let saslMechanismStrs=["EXTERNAL"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString().contains("IllegalArgumentException: SASL EXTERNAL is not available. Consider registering it with Xmpp"), true)
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_07(): Unit {
        let saslMechanismStrs=["DIGEST-MD5"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(saslMechanismStrs))
        @Assert(e.toString().contains("IllegalArgumentException: SASL DIGEST-MD5 is not available. Consider registering it with Xmpp"), true)
    }
    @TestCase
    func test_test_addEnabledSaslMechanism02_08(): Unit {
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(["Other"]))
        @Assert(e.toString(),"IllegalArgumentException: SASL Other is not available. Consider registering it with Xmpp")
    }
}
