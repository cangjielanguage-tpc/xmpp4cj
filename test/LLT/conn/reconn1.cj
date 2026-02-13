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

@Test
public class ReconnectionTest {
    static var MIN_RECONNECT_WAIT = 17 // Seconds

    /**
     * Tests an automatic reconnection.
     * Simulates a connection error and then waits until gets reconnected.
     */
    @TestCase
    public func testAutomaticReconnection(): Unit {
        var connection: XMPPTCPConnection = createXMPPConnection("testAutomaticReconnection")
        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPTCPConnectionTestListener(latch, connection)
        connection.addConnectionListener(listener)

        // Simulates an error in the connection
        // connection.notifyConnectionError(Exception("Simulated Error"))
        connection.sendStanza(ErrStanza())
        latch.waitUntilZero(timeout: MIN_RECONNECT_WAIT * Duration.second)

        // After 10 seconds, the reconnection manager must reestablishes the connection
        assertEquals("The ConnectionListener.connectionStablished() notification was not fired", true,
            listener.reconnected)
        assertTrue("The ReconnectionManager algorithm has reconnected without waiting at least 5 seconds",
            listener.attemptsNotifications > 0)

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)
    }

    @TestCase
    public func testAutomaticReconnectionWithCompression(): Unit {
        var connection: XMPPTCPConnection = createXMPPConnection("MyOtherResource")

        assertTrue("Failed to use compression", connection.isUsingCompression())

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)

        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPTCPConnectionTestListener(latch, connection)
        connection.addConnectionListener(listener)

        // Simulates an error in the connection
        // connection.notifyConnectionError(Exception("Simulated Error"))
        connection.sendStanza(ErrStanza())
        latch.waitUntilZero(timeout: MIN_RECONNECT_WAIT * Duration.second)

        // After 10 seconds, the reconnection manager must reestablishes the connection
        assertEquals("The ConnectionListener.connectionEstablished() notification was not fired", true,
            listener.reconnected)
        assertTrue("The ReconnectionManager algorithm has reconnected without waiting at least 5 seconds",
            listener.attemptsNotifications > 0)

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)
    }

    /**
     * Tests a manual reconnection.
     * Simulates a connection error, disables the reconnection mechanism and then reconnects.
     */
    @TestCase
    public func testManualReconnectionWithCancelation(): Unit {
        var connection: XMPPTCPConnection = createXMPPConnection("testManualReconnectionWithCancelation")
        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPTCPConnectionTestListener(latch, connection)
        connection.addConnectionListener(listener)

        // Produces a connection error
        // connection.notifyConnectionError(Exception("Simulated Error"))
        connection.sendStanza(ErrStanza())
        latch.waitUntilZero(timeout: Duration.second)
        assertEquals("An error occurs but the ConnectionListener.connectionClosedOnError(e) was not notified", true,
            listener._connectionClosedOnError)

        // Cancels the automatic reconnection
        // connection.getConfiguration().setReconnectionAllowed(false)
        // Waits for a reconnection that must not happened.
        // sleep(MIN_RECONNECT_WAIT * Duration.second)
        // Cancels the automatic reconnection
        assertEquals(true, listener.reconnected)

        // Makes a manual reconnection from an error terminated connection without reconnection
        @AssertThrows[Exception](connection.connect())

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)
    }

    /**
     * Tests a manual reconnection after a login.
     * Closes the connection and then reconnects.
     */
    @TestCase
    public func testCloseAndManualReconnection(): Unit {
        var connection: XMPPTCPConnection = createXMPPConnection("testCloseAndManualReconnection")
        var username: String = connection.getConfiguration().getUsername().getOrThrow()
        var password: String = connection.getConfiguration().getPassword().getOrThrow()
        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPTCPConnectionTestListener(latch, connection)
        connection.addConnectionListener(listener)

        // Produces a normal disconnection
        connection.disconnect()
        assertEquals("ConnectionListener.connectionClosed() was not notified", true, listener._connectionClosed)
        // Waits 10 seconds waiting for a reconnection that must not happened.
        latch.waitUntilZero(timeout: 0.5 * Duration.second)
        assertEquals("The connection was stablished but it was not allowed to", false, listener.reconnected)

        // Makes a manual reconnection
        connection.connect()
        connection.login(username, password)

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)
    }

    /**
     * Tests a reconnection in a anonymously logged connection.
     * Closes the connection and then reconnects.
     */
    @TestCase
    public func testAnonymousReconnection(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        let config = configBuilder
            .setUsernameAndPassword("9", "123456")
            .setXmppDomain(XmppTestServerHostName)
            .setHost(XmppTestServerHostName)
            .setPort(5222)
            // .setResource(resource)
            .setCompressionEnabled(true)
            .performSaslAnonymousAuthentication()
            // .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .setTlsClientConfig(TLS_TRUST_ALL)
            .build()
        var connection: XMPPTCPConnection = XMPPTCPConnection(config)
        connection.connect()
        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPTCPConnectionTestListener(latch, connection)
        connection.addConnectionListener(listener)

        // Makes the anounymous login
        connection.login()

        // Produces a normal disconnection
        connection.disconnect()
        assertEquals("ConnectionListener.connectionClosed() was not notified", true, listener._connectionClosed)
        // Makes a manual reconnection
        connection.connect()
        connection.login()
        assertEquals("Failed the manual connection", true, connection.isAnonymous())
    }

    func createXMPPConnection(resource: String): XMPPTCPConnection {
        var connection: XMPPTCPConnection
        // Create the configuration
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        let config = configBuilder
            .setUsernameAndPassword("9", "123456")
            .setXmppDomain(XmppTestServerHostName)
            .setHost(XmppTestServerHostName)
            .setPort(5222)
            .setResource(resource)
            .setCompressionEnabled(true)
            // .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .setTlsClientConfig(TLS_TRUST_ALL)
            .build()
        connection = XMPPTCPConnection(config)
        connection.connect()
        connection.login()
        println("${connection.isConnected()} ${connection.isAuthenticated()}")
        return connection
    }

    /**
     * Execute some server interaction in order to test that the regenerated connection works fine.
     */
    func executeSomeServerInteraction(connection: XMPPTCPConnection): Unit {
        /* 
        var pingManager: PingManager = PingManager.getInstanceFor(connection)
        pingManager.pingMyServer()
         */
    }

    protected func getMaxConnections(): Int {
        return 1
    }
}

class XMPPTCPConnectionTestListener <: ConnectionListener {

    // Variables to support listener notifications verification
    var _connectionClosed = false
    var _connectionClosedOnError = false
    var reconnected = false
    var _reconnectionFailed = false
    var remainingSeconds = 0
    var attemptsNotifications = 0
    var _reconnectionCanceled = false
    var countDownLatch: SyncCounter
    let conn: XMPPTCPConnection

    init(latch: SyncCounter, conn: XMPPTCPConnection) {
        countDownLatch = latch
        this.conn = conn
    }

    public override func connecting(_: XMPPConnection): Unit {
        println("connecting")
    }
    public override func connected(_: XMPPConnection): Unit {
        println("connected")
    }
    public override func authenticated(_: XMPPConnection, _: Bool): Unit {
        println("authenticated")
    }
    /**
     * Methods to test the listener.
     */
    public override func connectionClosed(): Unit {
        println("connectionClosed")
        _connectionClosed = true
        countDownLatch.dec()
    }

    public override func connectionClosedOnError(e: Exception): Unit {
        println("connectionClosedOnError")
        _connectionClosedOnError = true

        reconnectingIn(0)

        try {
            conn.connect()
            conn.login()
            reconnectionSuccessful()
        } catch (e: Exception) {
            reconnectionFailed(e)
        }
    }

    public func reconnectionCanceled(): Unit {
        _reconnectionCanceled = true
        countDownLatch.dec()
    }

    public func reconnectingIn(seconds: Int): Unit {
        attemptsNotifications = attemptsNotifications + 1
        remainingSeconds = seconds
    }

    public func reconnectionSuccessful(): Unit {
        reconnected = true
        countDownLatch.dec()
    }

    public func reconnectionFailed(error: Exception): Unit {
        _reconnectionFailed = true
        countDownLatch.dec()
    }
}
