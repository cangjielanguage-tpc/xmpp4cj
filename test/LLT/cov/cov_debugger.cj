// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main
import cangjie_tpc::xmpp4cj.connection.*
import std.unittest.testmacro.*
import std.collection.*

@Test
public func t0(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)
    let d = ConsoleDebuggerFactory.INSTANCE.create(connection)
    AbstractDebugger.printInterpreted = true
    d.onIncomingStreamElement(Compressed())
    // d.authenticated(connection,true)
    // d.connectionClosedOnError(Exception())
}

class Nonza0 <: Nonza {
    public func getNamespace(): String {
        throw Exception("1.1")
    }
    public func getElementName(): String {
        throw Exception("1.2")
    }
    public func toXML(xmlEnvironment: ?XmlEnvironment): CharSequence {
        throw Exception("1.3")
    }
}

@Test
public func t1(): Unit {
    ReconnectionManager.setEnabledPerDefault(true)
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let connection = XMPPTCPConnection(config)

    connection.connect()
    connection.login()
    connection.disconnect(None)
    connection.connect()
    connection.sendNonza(Nonza0())
    for (_ in 0..10) {
        sleep(Duration.millisecond * 500)
        if(connection.isConnected()){
            break
        }
    }
    println(connection.isConnected())
    // let d = ConsoleDebuggerFactory.INSTANCE.create(connection)
    // d.connected(connection)
    // d.authenticated(connection,true)
    // d.connectionClosedOnError(Exception())
}
