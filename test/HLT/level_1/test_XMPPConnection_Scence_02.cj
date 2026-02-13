// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.compress.*
import cangjie_tpc::xmpp4cj.packet.*
import std.time.*
import std.net.*
import stdx.net.tls.*
import std.fs.*
import std.io.*
import stdx.log.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{
    let XmppTestServerHostName="xmpp.testserver"
    @TestCase
    func test_Scence02_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
        let connectionConfiguration = configBuilder.build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
        conn1.connect()
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        conn1.login("test1","123456")
        @Assert(conn1.getConnectionCounter(),0)
        @Assert(conn1.getXMPPServiceDomain(),JidCreate.domainBareFrom(XmppTestServerHostName))
        @Assert(conn1.getHost().getOrThrow(),XmppTestServerHostName)    
        @Assert(conn1.getPort(),5222)
        @Assert(conn1.getUser().getOrThrow().toString().contains("1@${XmppTestServerHostName}"),true)
        @Assert(conn1.getStreamId().isNone(),false)
        @Assert(conn1.isConnected(),true)
        @Assert(conn1.isAuthenticated(),true)
        @Assert(conn1.isAnonymous(),false)
        @Assert(conn1.isSecureConnection(),false)
        @Assert(conn1.isUsingCompression(),true)
        @Assert(conn1.getStanzaFactory().buildIqData().getType(),IQType.get)
        @Assert(conn1.getStanzaFactory().buildMessageStanza().getType().isNone(),true)
        @Assert(conn1.getStanzaFactory().buildPresenceStanza().getType(),PresenceType.available)
        @Assert(conn1.getReplyTimeout().toSeconds(),5)
        @Assert(conn1.getConnectionCounter(),0)  //执行报错  https://gitcode.com/Cangjie-TPC/xmpp4cj/issues/196
        @Assert(conn1.getFromMode(),XMPPConnectionFromMode.OMITTED)   
        @Assert(conn1.getFeature(Compressed.QNAME).isNone(),true)
        @Assert(conn1.getFeature(CompressFeature.QNAME).isNone(),true)
        @Assert(conn1.hasFeature(CompressFeature.QNAME),false)
        @Assert(conn1.hasFeature(Compress.ELEMENT,Compress.NAMESPACE),false)
        @Assert(conn1.getLastStanzaReceived().toSeconds() >0,true) 
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect()
    }
    @TestCase
    func test_Scence02_02(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
        let connectionConfiguration = configBuilder.build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
        conn1.connect()
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        conn1.login("test1","123456")
        @Assert(conn1.getConnectionCounter(),1)
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect()
    }
    @TestCase
    func test_Scence02_03(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
        let connectionConfiguration = configBuilder.build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
        conn1.connect()
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        conn1.login("test1","123456")
        @Assert(conn1.getHost().getOrThrow(),XmppTestServerHostName)
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        conn1.disconnect()
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

