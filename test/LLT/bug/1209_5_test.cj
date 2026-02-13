// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
@Test
public class TestXMPPConnection{
    @TestCase
    func test_addStanzaListener_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addStanzaListener(lisener01,StanzaTypeFilter<Stanza>("Stanza"))
        conn1.connect() // 连接
        conn1.login()
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var logContentCur=lisener01.logContent.toString()
        @Assert(logContentCur.count("<presence"),2)
        @Assert(logContentCur.count("<iq"),1)
        @Assert(logContentCur.count("</iq>"),1)
    }
} 

// let XmppTestServerHostName = "xmpp.testserver"

public class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    public var logContent: StringBuilder= StringBuilder()
    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }
    public override func processStanza(packet: Stanza) {
        logContent.append(packet.toXML())
        logContent.append("\n")
    }
}