// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.feature.*
import std.time.*
import std.net.*
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "qq.com"
    @TestCase
    func test_setXmppDomain_05(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        let domainbareJid=JidCreate.domainBareFrom(XmppTestServerHostName)
        configBuilder.setXmppDomain(domainbareJid)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        let e:EndpointConnectionException=@AssertThrows[EndpointConnectionException](connection.connect())
        @Assert(e.toString().contains("EndpointConnectionException: The following addresses failed: 'RFC 6120 A/AAAA Endpoint"),true)
        connection.disconnect()
    }
}

