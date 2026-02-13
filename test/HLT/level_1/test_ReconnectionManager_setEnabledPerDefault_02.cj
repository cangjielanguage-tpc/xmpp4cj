// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj
// dependence: ./CommonReconnect.cj

@Test
public class TestReconnectionManager{            
    @TestCase
    func test_setEnabledPerDefault_02(): Unit {
        var conn=getConnection()
        conn.connect()
        ReconnectionManager.setEnabledPerDefault(false)
        var reconnectionManager=ReconnectionManager.getInstanceFor(conn)
        let rcl = ReconnectionListener1()
        reconnectionManager.addReconnectionListener(rcl)
        reconnectionManager.enableAutomaticReconnection()
        conn.sendStanza(ErrStanza())
        var totalTime=0
        while(totalTime<15000){
            rcl.latch.waitUntilZero(timeout: Duration.millisecond * 1)
            if(conn.isConnected()){
                break
            }
            totalTime+=1
        }
        @Assert(conn.isConnected(),true)
        while(totalTime<15000){
            rcl.latch.waitUntilZero(timeout: Duration.millisecond * 1)
            if(rcl.logContent.toString().contains("Reconnecting")){
                break
            }
            totalTime+=1
        }
        @Assert(rcl.logContent.toString().contains("Reconnecting"),true)
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