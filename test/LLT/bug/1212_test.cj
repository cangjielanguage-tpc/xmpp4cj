// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
import stdx.net.tls.*

@Test
func test_addEnabledSaslMechanism_03(): Unit {
    let saslMechanismStrs = ["ANONYMOUS", "CRAM-MD5", "DIGEST-MD5", "EXTERNAL", "	GSSAPI", "PLAIN", "SCRAM-SHA-1"]
    let config: XMPPTCPConnectionConfigurationBuilder = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    for (cursals in saslMechanismStrs) {
        // @AssertThrows[IllegalStateException](config.addEnabledSaslMechanism(cursals))
        // config.performSaslAnonymousAuthentication()
        // @Assert(e.toString(),"IllegalStateException: Enabled SASL mechanisms found")
    }
}

@Test
func test_AllGet_02(): Unit {
    //let syncCounter: SyncCounter = SyncCounter(1)
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
    let connectionConfiguration = configBuilder.build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
    conn1.connect()
    conn1.login("1", "123456")
    // @Assert(conn1.getConnectionCounter(),0)
    conn1.disconnect()
}


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
        conn1.login("1","123456")
        // @Assert(conn1.getConnectionCounter(),0)
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
        // @Assert(conn1.getConnectionCounter(),0)  //执行报错  https://gitcode.com/Cangjie-TPC/xmpp4cj/issues/196
        @Assert(conn1.getFromMode(),XMPPConnectionFromMode.OMITTED)   
        @Assert(conn1.getFeature(Compressed.QNAME).isNone(),true)
        @Assert(conn1.getFeature(CompressFeature.QNAME).isNone(),true)
        @Assert(conn1.hasFeature(CompressFeature.QNAME),false)
        @Assert(conn1.hasFeature(Compress.ELEMENT,Compress.NAMESPACE),false)
        @Assert(conn1.getLastStanzaReceived().toSeconds() >0,true) 
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
        conn1.login("1","123456")
        // @Assert(conn1.getConnectionCounter(),0)  //执行报错  https://gitcode.com/Cangjie-TPC/xmpp4cj/issues/196
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
        conn1.login("1","123456")
        @Assert(conn1.getHost().getOrThrow(),XmppTestServerHostName)    //编译报错         https://gitcode.com/Cangjie-TPC/xmpp4cj/issues/195
        conn1.disconnect()
    }
}