// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXMPPTCPConnection{
    @TestCase  
    func test_removeAllStanzaIdAcknowledgedListeners_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        var listen01=StanzaListener1(syncCounter, connection)
        try{
            connection.removeAllStanzaIdAcknowledgedListeners()
            @Assert(true)
        }catch(e:Exception){
            @Assert(false)
        }         
    }
}