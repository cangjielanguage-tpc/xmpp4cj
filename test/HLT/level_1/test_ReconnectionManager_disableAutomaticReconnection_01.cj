// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj
// dependence: ./CommonReconnect.cj

@Test
public class TestReconnectionManager{
    //public func disableAutomaticReconnection(): Unit
    @TestCase
    func test_disableAutomaticReconnection_01(): Unit {        
        let syncCounter: SyncCounter = SyncCounter(2)
        var conn=getConnection()
        var reconnectionManager=ReconnectionManager.getInstanceFor(conn)
        let rcl = ReconnectionListener1()
        reconnectionManager.addReconnectionListener(rcl)
        reconnectionManager.disableAutomaticReconnection()
        reconnectionManager.setFixedDelay(Duration.second * 2)
        reconnectionManager.setReconnectionPolicy(ReconnectionPolicy.FIXED_DELAY)
        conn.sendStanza(ErrStanza())
        rcl.latch.waitUntilZero(timeout: Duration.second * 1)
        @Assert(conn.isConnected(),false)
        rcl.latch.waitUntilZero(timeout: Duration.second * 2)
        @Assert(conn.isConnected(),false)
        @Assert(rcl.logContent.toString().contains("Reconnecting"),false)
        conn.disconnect()
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