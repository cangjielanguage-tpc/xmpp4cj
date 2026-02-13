// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*
import stdx.net.tls.*
import std.fs.*
import std.io.*
import stdx.log.*
import std.sync.SyncCounter

@Test
public class TestAbstractXMPPConnection{
    let XmppTestServerHostName="xmpp.testserver"
    @TestCase
    func test_getConfiguration_01(): Unit {
        var getConfiguration=getConnection().getConfiguration()
        @Assert(getConfiguration is ConnectionConfiguration,true)
    }
    @TestCase
    func test_getXMPPServiceDomain_01(): Unit {
        var getXMPPServiceDomain=getConnection().getXMPPServiceDomain()
        @Assert(getXMPPServiceDomain.toString(),XmppTestServerHostName)
    }
    @TestCase
    func test_getHost_01(): Unit {
        var getHost=getConnection().getHost()
        @Assert(getHost.isNone(),true)
    }
    @TestCase
    func test_getPort_01(): Unit {
        var getPort=getConnection().getPort()
        @Assert(getPort,-1)
    }
    @TestCase
    func test_getUser_01(): Unit {
        var getUser=getConnection().getUser()
        @Assert(getUser.isNone(),true)
    }
    @TestCase
    func test_getStreamId_01(): Unit {
        var getUser=getConnection().getStreamId()
        @Assert(getUser.isNone(),true)
    }
    func getConnection():XMPPTCPConnection{
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  conn1
    }
}