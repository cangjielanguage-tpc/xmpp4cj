// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.time.*

@Test
public class TestXMPPTCPConnectionConfiguration{
    let errorServer="cn"
    @TestCase
    func test_XMPPTCPConnectionConfiguration_getConnectTimeout_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(errorServer)
        .performSaslAnonymousAuthentication()
        let configurationXmpp = configBuilder.build()
        @Assert(configurationXmpp.getConnectTimeout(),Duration.second * 30)
    }
}