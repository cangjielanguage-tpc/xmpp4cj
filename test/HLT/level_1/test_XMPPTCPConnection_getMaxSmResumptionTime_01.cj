// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import stdx.log.*
import std.sync.SyncCounter
var caseNum=0
@Test
public class TestXMPPTCPConnection{
    @TestCase  
    func test_getMaxSmResumptionTime_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.getMaxSmResumptionTime(),Duration.second * Int64.Max)
        connection.disconnect()
    }
}


