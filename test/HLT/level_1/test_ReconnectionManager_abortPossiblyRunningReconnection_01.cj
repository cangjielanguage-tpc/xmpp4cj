// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj
// dependence: ./CommonReconnect.cj
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import stdx.net.tls.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.modular.*


@Test
public class TestReconnectionManager{
    @TestCase
    func test_abortPossiblyRunningReconnection_01(): Unit {   //可能偶先报错，和链接时间有关
        var conn=getConnection()
        conn.connect()
        var reconnectionManager=ReconnectionManager.getInstanceFor(conn)
        let rcl = ReconnectionListener1()
        reconnectionManager.addReconnectionListener(rcl)
        reconnectionManager.enableAutomaticReconnection()
        reconnectionManager.setFixedDelay(Duration.second * 2)
        reconnectionManager.setReconnectionPolicy(ReconnectionPolicy.FIXED_DELAY)
        conn.sendStanza(ErrStanza())
        rcl.latch.waitUntilZero(timeout: Duration.second * 1)
        @Assert(conn.isConnected(),false)
        reconnectionManager.abortPossiblyRunningReconnection()
        var totalTime=0
        while(conn.isConnected() && totalTime<3000){
            rcl.latch.waitUntilZero(timeout: Duration.millisecond * 1)
            totalTime+=1
        }
        totalTime=0
        while(!conn.isConnected() && totalTime<3000){
            rcl.latch.waitUntilZero(timeout: Duration.millisecond * 1)
            totalTime+=1
        }
        totalTime=0
        while(!rcl.logContent.toString().contains("Reconnecting") && totalTime<3000){
            rcl.latch.waitUntilZero(timeout: Duration.millisecond * 1)
            totalTime+=1
        }//以循环等待的方式确认校验值能准确获取到
        conn.disconnect()
    }
    @TestCase
    func test_abortPossiblyRunningReconnection_02(): Unit {
        var conn=getConnection()
        conn.connect()
        var reconnectionManager=ReconnectionManager.getInstanceFor(conn)
        let rcl = ReconnectionListener1()
        reconnectionManager.addReconnectionListener(rcl)
        reconnectionManager.enableAutomaticReconnection()
        reconnectionManager.setFixedDelay(Duration.second * 2)
        reconnectionManager.setReconnectionPolicy(ReconnectionPolicy.FIXED_DELAY)
        conn.sendStanza(ErrStanza())
        rcl.latch.waitUntilZero(timeout: Duration.second * 1)
        @Assert(conn.isConnected(),false)
        rcl.latch.waitUntilZero(timeout: Duration.second * 2)
        @Assert(conn.isConnected(),true)
        @Assert(rcl.logContent.toString().contains("Reconnecting"),true)
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