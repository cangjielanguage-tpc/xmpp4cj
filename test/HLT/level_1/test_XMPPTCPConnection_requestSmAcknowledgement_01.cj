// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXMPPTCPConnection{
    @TestCase  
    func test_requestSmAcknowledgement_01(): Unit {        //无效果
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        let e:StreamManagementNotEnabledException=@AssertThrows[StreamManagementNotEnabledException](connection.requestSmAcknowledgement())
        @Assert(e.toString().contains("StreamManagementNotEnabledException"),true)
    }
}


