// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

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
    //添加链接监听
    @TestCase
    func test_addConnectionListener_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01=myConnectionListener(conn1)
        conn1.addConnectionListener(lisener01)
        conn1.connect() // 连接
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var logLisener=lisener01.connectListen.toString()
        @Assert(logLisener.contains("XMPPConnection connected (XMPPTCPConnection[not-authenticated] (0))"),true)
    }
    @TestCase
    func test_addConnectionListener_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01=myConnectionListener(conn1)
        var lisener02=myConnectionListener02(conn1)
        conn1.addConnectionListener(lisener01)
        conn1.addConnectionListener(lisener02)
        conn1.connect() // 连接
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var logLisener01=lisener01.connectListen.toString()
        @Assert(logLisener01.contains("XMPPConnection connected (XMPPTCPConnection[not-authenticated]"),true)
        var logLisener02=lisener02.connectListen.toString()
        @Assert(logLisener02.contains("myConnectionListener02 XMPPConnection connected (XMPPTCPConnection[not-authenticated]"),true)
    }
}

func getSem(count:Int):Semaphore {
    let s = Semaphore(count)
    s.acquire(amount:count)
    s
}

public class myConnectionListener<:ConnectionListener{
    let val_connection: XMPPConnection
    public var connectListen=StringBuilder()
    let connectedCount =   getSem(100)
    let authenticatedCount =   getSem(100)
    let connectionClosedCount =   getSem(100)
    let connectionClosedOnErrorCount =   getSem(100)
    init(val_connection: XMPPConnection) {
        this.val_connection = val_connection
    }

    public override func connected(connection: XMPPConnection): Unit {
        this.connectListen.append("XMPPConnection connected (${connection})\n")
        connectedCount.release()
    }

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {
        var logString: String = "XMPPConnection authenticated (${connection})"
        if (resumed) {
            logString += " and resumed"
        }
        this.connectListen.append("${logString}\n")
        authenticatedCount.release()
    }

    public override func connectionClosed(): Unit {
        this.connectListen.append("XMPPConnection closed (${val_connection})\n")
        connectionClosedCount.release()
    }

    public override func connectionClosedOnError(e: Exception): Unit {
        this.connectListen.append("XMPPConnection closed due to an exception (${val_connection})\n")
        connectionClosedOnErrorCount.release()
    }
}
public class myConnectionListener02<:ConnectionListener{
    let val_connection: XMPPConnection
    public var connectListen=StringBuilder()
    init(val_connection: XMPPConnection) {
        this.val_connection = val_connection
    }

    public override func connected(connection: XMPPConnection): Unit {
        this.connectListen.append(" myConnectionListener02 XMPPConnection connected (${connection})\n")
    }

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {
        var logString: String = "myConnectionListener02 XMPPConnection authenticated (${connection})"
        if (resumed) {
            logString += " and resumed"
        }
        this.connectListen.append("${logString}\n")
    }

    public override func connectionClosed(): Unit {
        this.connectListen.append("myConnectionListener02 XMPPConnection closed (${val_connection})\n")
    }

    public override func connectionClosedOnError(e: Exception): Unit {
        this.connectListen.append("myConnectionListener02 XMPPConnection closed due to an exception (${val_connection})\n")
    }
}


