// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.feature.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{ 
    @TestCase
    func test_nextResultOrThrow02_03(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        let e:Xmpp4cjException=@AssertThrows[Xmpp4cjException](stanzaCollector.nextResultOrThrow(Duration.second*0))
        println(e)
        @Assert(e.toString().contains("Xmpp4cjException: The connection XMPPTCPConnection"),true)
        @Assert(e.toString().contains("is no longer connected while waiting for response with StanzaTypeFilter: IQ"),true)
    }
    @TestCase
    func test_nextResultOrThrow02_04(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        let e:Xmpp4cjException=@AssertThrows[Xmpp4cjException](stanzaCollector.nextResultOrThrow(Duration.second*0))
        @Assert(e.toString().contains("Xmpp4cjException: The connection XMPPTCPConnection"),true)
        @Assert(e.toString().contains("is no longer connected while waiting for response with None"),true)
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

