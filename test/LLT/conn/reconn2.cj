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

class ConnectionListener1 <: ConnectionListener {
    let latch = SyncCounter(1)
    public override func connected(_: XMPPConnection): Unit {
        latch.dec()
    }
    public override func connectionClosed(): Unit {
    }

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {
    }

    public override func connectionClosedOnError(e: Exception): Unit {
    }
}

/*一个简单的用例 发送ErrStaza触发异常断连 2秒后开始重连 */
@Test
public func ReconnectionManagerTest3(): Unit {
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

    connection.connect()

    let rcl = ReconnectionListener1()
    reconnectionManager.addReconnectionListener(rcl)
    reconnectionManager.enableAutomaticReconnection()
    reconnectionManager.setFixedDelay(Duration.second * 2)

    let l1 = ConnectionListener1()
    connection.addConnectionListener(l1)
    connection.sendStanza(ErrStanza())

    l1.latch.waitUntilZero(timeout:Duration.second * 5)
    println(connection.isConnected())
}
