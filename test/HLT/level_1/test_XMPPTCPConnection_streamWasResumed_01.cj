// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*
import std.net.*
@Test
public class TestXMPPTCPConnection{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_streamWasResumed_01(): Unit {
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let connection: XMPPTCPConnection = XMPPTCPConnection(config1)
        connection.connect()
        connection.login()
        @Assert(connection.streamWasResumed(),false)
        connection.disconnect()
    }
}

