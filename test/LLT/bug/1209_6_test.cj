// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
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
    //账号登录
    @TestCase
    func test_AllGet_02(): Unit {
        //let syncCounter: SyncCounter = SyncCounter(1)
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setCompressionEnabled(true)
        let connectionConfiguration = configBuilder.build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(connectionConfiguration)
        conn1.connect()
        conn1.login("1","123456")
        @Assert(conn1.getConnectionCounter(),0)
        conn1.disconnect()
    }
}
