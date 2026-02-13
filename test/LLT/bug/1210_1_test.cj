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

@Test
func test_sendIqRequestAsync02_02(): Unit {
    let syncCounter: SyncCounter = SyncCounter(2)
    // 接收消息
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .enableDefaultDebugger()
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    conn1.connect() // 连接
    conn1.login()
    var iqReply = conn1.sendIqRequestAsync(Session(), Duration.second * 0)
    try {
        println(iqReply.get().toXML().toString())
    } catch (e: Exception) {
        e.printStackTrace()
    }
    conn1.disconnect() // 从服务器断开连接
}
