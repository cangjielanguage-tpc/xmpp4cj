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
    func test_addStanzaDroppedListener_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        var tjyf=IQTypeFilter.RESULT
        var listen01=StanzaListener1(syncCounter, connection)
        connection.addStanzaDroppedListener(listen01)
        connection.connect()
        var iq01=ElementRegister()
        connection.sendStanza(iq01)
        connection.login("test2","123456")
        @Assert(connection.isConnected(),true)
        var iq02=ElementUnRegister()
        connection.sendStanza(iq02)
        connection.disconnect()
        var log=listen01.logContent.toString()
        @Assert(log.count("<presence"),0)
        @Assert(log.count("<iq"),0)
    }
}
//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
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

