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

@Test
public class TestXMPPTCPConnection{
    @TestCase  
    func test_addStanzaIdAcknowledgedListener_01(): Unit {      
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
                     .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        var listen01=StanzaListener1(syncCounter, connection)
        let e:StreamManagementNotEnabledException=@AssertThrows[StreamManagementNotEnabledException](connection.addStanzaIdAcknowledgedListener("id-111",listen01))
        @Assert(e.toString().contains("StreamManagementNotEnabledException"),true)
    }
}

