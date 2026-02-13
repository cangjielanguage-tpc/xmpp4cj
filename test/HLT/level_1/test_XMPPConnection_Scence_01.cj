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
    //未登录
    @TestCase
    func test_Scence01_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
        let connectionConfiguration = configBuilder.build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
        @Assert(conn1.getXMPPServiceDomain(),JidCreate.domainBareFrom(XmppTestServerHostName))
        @Assert(conn1.getPort(),-1)
        @Assert(conn1.getUser().isNone(),true)
        @Assert(conn1.getStreamId().isNone(),true)
        @Assert(conn1.isConnected(),false)
        @Assert(conn1.isAuthenticated(),false)
        @Assert(conn1.isAnonymous(),false)
        @Assert(conn1.isSecureConnection(),false)
        @Assert(conn1.isUsingCompression(),false)
        @Assert(conn1.getStanzaFactory().buildIqData().getType(),IQType.get)
        @Assert(conn1.getStanzaFactory().buildMessageStanza().getType().isNone(),true)
        @Assert(conn1.getStanzaFactory().buildPresenceStanza().getType(),PresenceType.available)
        @Assert(conn1.getReplyTimeout().toSeconds(),5)
        @Assert(conn1.getConnectionCounter(),0) //0
        @Assert(conn1.getFromMode(),XMPPConnectionFromMode.OMITTED)   //XMPPConnectionFromMode.UNCHANGED/OMITTED/USER
        @Assert(conn1.getFeature(Compressed.QNAME).isNone(),true)
        @Assert(conn1.getFeature(CompressFeature.QNAME).isNone(),true)
        @Assert(conn1.hasFeature(CompressFeature.QNAME),false)
        @Assert(conn1.hasFeature(Compress.ELEMENT,Compress.NAMESPACE),false)
        @Assert(conn1.getLastStanzaReceived().toSeconds(),0)
    }

    @TestCase
    func test_Scence01_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
        let connectionConfiguration = configBuilder.build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
        @Assert(conn1.getHost().isNone(),true)  //编译报错         https://gitcode.com/Cangjie-TPC/xmpp4cj/issues/195
    }
}

