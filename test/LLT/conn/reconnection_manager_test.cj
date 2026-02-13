// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.modular.*

class ErrStanza <: Stanza {
    let msg: Message = StanzaBuilder.buildMessage().build();

    public func toString(): String {
        return msg.toString();
    }

    public func getElementName(): String {
        return msg.getElementName();
    }

    public func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        throw Exception("stop")
    }
}

class ReconnectionListener1 <: ReconnectionListener {
    let latch = SyncCounter(1)
    public override func reconnectingIn(seconds: Duration): Unit {
        println("Reconnecting in ${seconds.toSeconds()} seconds")
    }
    public override func reconnectionFailed(e: Exception): Unit {
        println("reconnectionFailed in ${e}")
    }
}

@Test
public func ReconnectionManagerTest(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        // .setCompressionEnabled(true)
        // .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .setTlsClientConfig(TLS_TRUST_ALL)
        .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)

    ReconnectionManager.setEnabledPerDefault(true) // 全局设置是否启用重新连接
    ReconnectionManager.setDefaultFixedDelay(Duration.second) // 全局设置重新连接的默认延迟
    ReconnectionManager.setDefaultReconnectionPolicy(ReconnectionPolicy.RANDOM_INCREASING_DELAY) // 全局设置重新连接的默认延迟
    let reconnectionManager = ReconnectionManager.getInstanceFor(connection)
    reconnectionManager.enableAutomaticReconnection()
    @Assert(reconnectionManager.isAutomaticReconnectEnabled(), true)
    reconnectionManager.disableAutomaticReconnection()
    @Assert(reconnectionManager.isAutomaticReconnectEnabled(), false)
    reconnectionManager.enableAutomaticReconnection()
    @Assert(reconnectionManager.isAutomaticReconnectEnabled(), true)

    let rcl = ReconnectionListener1()
    reconnectionManager.removeReconnectionListener(rcl)
    reconnectionManager.addReconnectionListener(rcl)
    reconnectionManager.setFixedDelay(Duration.second)
    reconnectionManager.setReconnectionPolicy(ReconnectionPolicy.RANDOM_INCREASING_DELAY)
    reconnectionManager.setFixedDelay(Duration.second)

    // reconnectionManager.isReconnectionPossible(connection)

    connection.connect()
    connection.login()

    // connection.notifyConnectionError(Exception("test"))
    connection.sendStanza(ErrStanza())

    rcl.latch.waitUntilZero(timeout: Duration.second * 20)
    @Assert(connection.isConnected(), false)
}

@Test
public func ReconnectionManagerTest2(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)

    let reconnectionManager = ReconnectionManager.getInstanceFor(connection)

    // @Assert(reconnectionManager.isReconnectionPossible(connection))

    connection.connect()
    // reconnectionManager.reconnect()
    // connection.login()
    // reconnectionManager.reconnect()
    // reconnectionManager.reconnect()

    println(ReconnectionPolicy.RANDOM_INCREASING_DELAY)
    println(ReconnectionPolicy.FIXED_DELAY)

    let rcl = ReconnectionListener1()
    reconnectionManager.addReconnectionListener(rcl)

    // connection.notifyConnectionError(Exception("test"))
    connection.sendStanza(ErrStanza())
    reconnectionManager.abortPossiblyRunningReconnection()
    reconnectionManager.abortPossiblyRunningReconnection()

    @Assert(connection.isConnected())
    @AssertThrows[Exception](connection.connect())
    connection.disconnect(None)
    @Assert(connection.isConnected(), false)
}
