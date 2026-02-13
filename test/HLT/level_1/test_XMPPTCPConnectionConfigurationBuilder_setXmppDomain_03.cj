// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let errorHost="ci.test"
    @TestCase
    func test_setXmppDomain_03(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(errorHost)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        let e:EndpointConnectionException=@AssertThrows[EndpointConnectionException](connection.connect())
        @Assert(e.toString().contains("EndpointConnectionException: Could not lookup the following endpoints: RemoteConnectionEndpointLookupFailure(description='DNS lookup exception for ci.test')"),true)
        connection.disconnect()
    }
}

