// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import stdx.net.tls.*
import std.sync.SyncCounter
@Test
public class TestAbstractXMPPConnection{    
    @TestCase
    func test_login03_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        let conn1=getConnection()
        conn1.connect() // 连接
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        conn1.login("test1","123456",Resourcepart.fromOrThrowUnchecked("test2"))
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect() // 从服务器断开连接
        @Assert(lisener01.logContent.toString().isEmpty(),false)
    }

    func getConnection():XMPPTCPConnection{
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) 
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  conn1
    }
}

//定义查询当前用户,联系人列表
class ElementListFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' type='set'><query xmlns='jabber:iq:roster'/></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test1</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}




