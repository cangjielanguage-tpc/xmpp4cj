// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.compress.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

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

@Test
public class TestXMPPConnection{
    @TestCase
    func test_sendNonza_01(): Unit {
        let tmp=getConnection()
        let conn1=tmp[0]
        let syncCounter=tmp[1]
        conn1.connect()
        conn1.login()
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01,StanzaTypeFilter<Stanza>("Stanza")) 
        var nonza=Compress("zlib")
        conn1.sendNonza(nonza)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        println(lisener01.logContent)
        // @Assert(false)
    }
    @TestCase
    func test_sendNonza_02(): Unit {
        let tmp=getConnection()
        let conn1=tmp[0]
        let syncCounter=tmp[1]
        conn1.connect()
        conn1.login()
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01,StanzaTypeFilter<Stanza>("Stanza"))
        var nonza= Failure(FailureCompressFailureError.processing_failed)
        conn1.sendNonza(nonza)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        // @Assert(false)
    }
    func getConnection():(XMPPTCPConnection,SyncCounter){
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  (conn1,syncCounter)
    }
}