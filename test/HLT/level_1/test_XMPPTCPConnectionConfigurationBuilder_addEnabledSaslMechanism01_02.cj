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
    func test_addEnabledSaslMechanism01_01(): Unit {
        let saslMechanismStrs=["JIVE-SHAREDSECRET","NTLM"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        for (cursals in saslMechanismStrs) {
            let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(cursals))
            @Assert(e.toString(),"IllegalArgumentException: SASL ${cursals} is not available. Consider registering it with Xmpp")
        }
    }
    @TestCase
    func test_addEnabledSaslMechanism01_02(): Unit {
        let saslMechanismStrs=["ANONYMOUS","CRAM-MD5","DIGEST-MD5","EXTERNAL","	GSSAPI","JIVE-SHAREDSECRET","PLAIN","SCRAM-SHA-1","NTLM"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        for (cursals in saslMechanismStrs) {
            let e:IllegalStateException=@AssertThrows[IllegalStateException](config.addEnabledSaslMechanism(cursals))
            @Assert(e.toString(),"IllegalStateException: The enabled SASL mechanisms are sealed, you can not add new ones")
        }
    }
    @TestCase
    func test_addEnabledSaslMechanism01_03(): Unit {
        let saslMechanismStrs=["ANONYMOUS","SCRAM-SHA-1"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        for (cursals in saslMechanismStrs) {
            config.addEnabledSaslMechanism(cursals)
            let e:IllegalStateException=@AssertThrows[IllegalStateException](config.performSaslAnonymousAuthentication())
            @Assert(e.toString(),"IllegalStateException: Enabled SASL mechanisms found")
        }
    }
    @TestCase
    func test_addEnabledSaslMechanism01_04(): Unit {
        let saslMechanismStrs=["CRAM-MD5","DIGEST-MD5","EXTERNAL","	GSSAPI","PLAIN"]
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        for (cursals in saslMechanismStrs) {
            let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism(cursals))
            @Assert(e.toString(),"IllegalArgumentException: SASL ${cursals} is not available. Consider registering it with Xmpp")
        }
    }
    @TestCase
    func test_addEnabledSaslMechanism01_05(): Unit {
        let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](config.addEnabledSaslMechanism("Other"))
        @Assert(e.toString(),"IllegalArgumentException: SASL Other is not available. Consider registering it with Xmpp")
    }
}
