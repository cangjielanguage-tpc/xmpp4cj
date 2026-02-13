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
public class TestXMPPConnection{
    @TestCase
    func test_getCollectedStanzasAfterCancelled02_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        let e:IllegalStateException=@AssertThrows[IllegalStateException](stanzaCollector.getCollectedStanzasAfterCancelled())
        @Assert(e.toString(),"IllegalStateException: Stanza collector was not yet cancelled")

    }
    @TestCase
    func test_getCollectedStanzasAfterCancelled02_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        let e:IllegalStateException=@AssertThrows[IllegalStateException](stanzaCollector.getCollectedStanzasAfterCancelled())
        @Assert(e.toString(),"IllegalStateException: Stanza collector was not yet cancelled")

    }
}
public func getStanzaCollectorByFilter():StanzaCollector{
    let syncCounter: SyncCounter = SyncCounter(2)
    // 接收消息
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    var stanzaCollector=conn1.createStanzaCollector(StanzaTypeFilter<IQ>("IQ"))
    conn1.connect() // 连接
    conn1.login() // 登录

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
    return stanzaCollector
}
public func getStanzaCollectorBynewConfiguration():StanzaCollector{
    let syncCounter: SyncCounter = SyncCounter(2)
    // 接收消息
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    var stanzaCollector=conn1.createStanzaCollector(StanzaCollector.newConfiguration())
    conn1.connect() // 连接
    conn1.login() // 登录

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
    return stanzaCollector
}
