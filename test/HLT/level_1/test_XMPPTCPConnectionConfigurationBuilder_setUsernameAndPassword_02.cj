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
    func test_setUsernameAndPassword_02(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
            .setUsernameAndPassword("test-01", "123456")
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        let e:SASLErrorException=@AssertThrows[SASLErrorException](connection.login())
        @Assert(e.toString(),"SASLErrorException: SASLError using SCRAM-SHA-1: Some(not-authorized)")
        @Assert(e.message,"SASLError using SCRAM-SHA-1: Some(not-authorized)")
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),false)
        var iq02=ElementUnRegister()
        connection.sendStanza(iq02)
        connection.disconnect()
    }
}