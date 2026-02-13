// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.feature.*
import std.net.*
import std.fs.*
import std.sync.SyncCounter
import stdx.log.*
import std.io.*
import std.time.*

var caseNum=0
@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setConnectTimeout_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain("error.com") // 设置XMPP域
            .setConnectTimeout(Duration.second*5)
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let connection: XMPPTCPConnection = XMPPTCPConnection(config1)
        var start=DateTime.now()
        var result:Future<Unit>=spawn{
            let e:EndpointConnectionException=@AssertThrows[EndpointConnectionException](connection.connect())
            @Assert(e.toString().contains("EndpointConnectionException: The following addresses failed: 'RFC 6120 A/AAAA Endpoint"),true)
            @Assert(e.toString().contains("SocketException: Failed to connect"),true)
        }
        connection.disconnect()
    }
}