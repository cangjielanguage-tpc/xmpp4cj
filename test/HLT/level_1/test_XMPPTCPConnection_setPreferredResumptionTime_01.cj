// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXMPPTCPConnection{
    @TestCase  
    func test_setPreferredResumptionTime_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.setPreferredResumptionTime(Duration.second*0)
        connection.connect()
        var iq02=ElementRegister2()
        connection.sendStanza(iq02)
        connection.login("test2","123456")
        @Assert(connection.isConnected(),true)
        var iq03=ElementUnRegister()
        connection.sendStanza(iq03)
        connection.disconnect()
    }
    @TestCase
    func test_setPreferredResumptionTime_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.setPreferredResumptionTime(Duration.second*10)
        connection.connect()
        var iq02=ElementRegister2()
        connection.sendStanza(iq02)
        connection.login("test2","123456")
        @Assert(connection.isConnected(),true)
        var iq03=ElementUnRegister()
        connection.sendStanza(iq03)
        connection.disconnect()
    }
}
//定义查询当前用户添加联系人
class ElementRegister2 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test2</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}

