// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

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
    func test_nextResultOrThrow01_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        var nextResult01=stanzaCollector.nextResultOrThrow().toString()
        @Assert(nextResult01.contains("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [to=xmpp.testserver/"),true)
        @Assert(nextResult01.contains("type=result"),true)
    }
    @TestCase
    func test_nextResultOrThrow01_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        var nextResult01=stanzaCollector.nextResultOrThrow().toString()
        @Assert(nextResult01.contains("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [to=xmpp.testserver/"),true)
        @Assert(nextResult01.contains("type=result"),true)
    }
    @TestCase
    func test_nextResultOrThrow01_03(): Unit {
        var stanzaCollector=getStanzaCollectorByFilterAfterDisconnect()
        let e:Xmpp4cjException=@AssertThrows[Xmpp4cjException](stanzaCollector.nextResultOrThrow())
        @Assert(e.toString().contains("Xmpp4cjException: The connection XMPPTCPConnection"),true)
        @Assert(e.toString().contains("is no longer connected while waiting for response with StanzaTypeFilter: IQ"),true)
    }
    @TestCase
    func test_nextResultOrThrow01_04(): Unit {   
        var stanzaCollector=getStanzaCollectorBynewConfigurationAfterDisconnect()
        let e:Xmpp4cjException=@AssertThrows[Xmpp4cjException](stanzaCollector.nextResultOrThrow())
        @Assert(e.toString().contains("Xmpp4cjException: The connection XMPPTCPConnection"),true)
        @Assert(e.toString().contains("is no longer connected while waiting for response with None"),true)
    }
    func getStanzaCollectorByFilterAfterDisconnect():StanzaCollector{
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        conn1.login() // 登录
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var stanzaCollector=conn1.createStanzaCollector(StanzaTypeFilter<IQ>("IQ"))
        return stanzaCollector
    }
    func getStanzaCollectorBynewConfigurationAfterDisconnect():StanzaCollector{
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        conn1.login() // 登录

        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var stanzaCollector=conn1.createStanzaCollector(StanzaCollector.newConfiguration())
        return stanzaCollector
    }
}

