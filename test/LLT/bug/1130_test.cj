// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
import stdx.net.tls.*

// @Test
func t182(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setTlsClientConfig(TlsClientConfig())
    // .performSaslAnonymousAuthentication()
    // .enableDefaultDebugger()
    // .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let conn = XMPPTCPConnection(configBuilder.build())
    // let conn = XMPPTCPConnection("2@xmpp.testserver", "123456")
    conn.connect()
    println(conn.isConnected())
}

// @Test
func test_setSecurityMode04_01(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        // .setConnectTimeout(Duration.second)
        .setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
    let connection = XMPPTCPConnection(configBuilder.build())
    connection.connect()
}

// @Test
func test_setSecurityMode04_03(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setXmppDomain(XmppTestServerHostName)
        // .setXmppDomain("localhost")
        .setPort(52321)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
    let config = configBuilder.build()
    println(config.getPort())
    let connection = XMPPTCPConnection(config)
    connection.connect()
    // connection.login()
    // let e: XmppWrappedException = @AssertThrows[XmppWrappedException](connection.connect())
    // @Assert(e.toString(),"XmppWrappedException: Socket is already closed")
}

// @Test
func test_XMPPTCPConnectionConfiguration_getConnectTimeout_02(): Unit {
    let errorServer = "www.baidu"
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setXmppDomain(errorServer)
        .setHost(errorServer)
        .setPort(5222)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = XMPPTCPConnection(configBuilder.build())
    var start = DateTime.now()
    var result: Future<Unit> = spawn {
        connection.connect()
    }
    result.get()
    var end = DateTime.now()
    let dur = (end - start).toSeconds()
    println("dur=${dur}")
    @Assert(dur<=30 && dur>=25,true)
}

// @Test
func test_init02_01(): Unit {
    var cfg = DEFAULT_TLS_CFG
    cfg.verifyMode = CertificateVerifyMode.TrustAll
    let connection = XMPPTCPConnection("2@xmpp.testserver", "123456", "xmpp.testserver")
    connection.connect()
    connection.login()
    @Assert(connection.isConnected(),true)
    @Assert(connection.isAuthenticated(),true)
    @Assert(connection.isSecureConnection(),true)
    connection.disconnect()
    @Assert(connection.isConnected(),false)
}

class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        println(packet.toXML())
    }
}

@Test
func test_sendNonza_01(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = XMPPTCPConnection(configBuilder.build())
    // caseNum = 1
    connection.addSyncStanzaListener(StanzaListener1(syncCounter, connection), StanzaTypeFilter<Stanza>("Stanza"))
    connection.connect()
    connection.login()
    var nonza = Compress("zlib")
    connection.sendNonza(nonza)
    @Assert(connection.isConnected(),true)
    println(connection.isConnected())
    connection.disconnect()
    println(connection.isConnected())
    sleep(Duration.second)
    //var tmp=File.readFrom("./sendNonza_${caseNum}.txt")
    //@Assert(String.fromUtf8(tmp).contains("xml:lang=\'usa\'"),true)
}

@Test
func test_AllGet_01(): Unit {
    let syncCounter: SyncCounter = SyncCounter(1)
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder.setXmppDomain(XmppTestServerHostName).setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connectionConfiguration = configBuilder.build()
    @Assert(connectionConfiguration.getXmlLang(),"zh-CN")
}
