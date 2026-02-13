// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj
// dependence: ./CommonReconnect.cj

@Test
public class TestReconnectionManager{
    @TestCase
    func test_removeReconnectionListener_01(): Unit {
        var conn=getConnection()
        conn.connect()
        var reconnectionManager=ReconnectionManager.getInstanceFor(conn)
        let rcl = ReconnectionListener1()
        reconnectionManager.addReconnectionListener(rcl)
        reconnectionManager.removeReconnectionListener(rcl)
        reconnectionManager.enableAutomaticReconnection()
        reconnectionManager.setFixedDelay(Duration.second * 2)
        reconnectionManager.setReconnectionPolicy(ReconnectionPolicy.FIXED_DELAY)
        conn.sendStanza(ErrStanza())
        rcl.latch.waitUntilZero(timeout: Duration.second * 5)
        @Assert(conn.isConnected(),true)
        @Assert(rcl.logContent.toString().contains("Reconnecting"),false)
        conn.disconnect()
    }
    func getConnection():XMPPTCPConnection{
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