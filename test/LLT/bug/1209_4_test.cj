// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection {
    //双方变更状态，消息交互情况
    //发送对象(非匿名-非匿名)在PresenceMode的各种情况下，是否能发送消息
    @TestCase
    func test_addStanzaSendingListener_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            // .enableDefaultDebugger()
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01 = StanzaListener1(syncCounter, conn1)

        conn1.addPresenceInterceptor(
            HashableConsumer<PresenceBuilder> {
                preBuilder => println("01.1 ${preBuilder.build().toXML()}")
            },
            LambdaPredicate<Presence> {p => true}
        )
        conn1.addStanzaSendingListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))

        conn1.connect() // 连接
        conn1.login()
        sleep(Duration.second)
        conn1.disconnect() // 从服务器断开连接
        syncCounter.waitUntilZero(timeout: Duration.second * 10)
        sleep(Duration.second)
        var logContentCur = lisener01.logContent.toString()
        println("<--\n${logContentCur}\n-->")
        @Assert(logContentCur.count("<presence")>0)
        @Assert(logContentCur.count("<iq"),1)
        @Assert(logContentCur.count("</iq>"),1)
    }
}

// let XmppTestServerHostName = "xmpp.testserver"

public class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    public var logContent: StringBuilder = StringBuilder()
    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        logContent.append("packet.toXML(): ")
        logContent.append(packet.toXML())
        logContent.append("\n")
        if(packet is Presence) {
            syncCounter.dec()
        }
    }
}
