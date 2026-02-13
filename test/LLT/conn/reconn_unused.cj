/// DEPENDENCE: ../z_test.cj ../log.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
/// EXEC: ./main 
//--filter=*.*
// 对标库无效用例
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.modular.*

@Test
public class ReconnectionTest {
    private static var MIN_RECONNECT_WAIT = 17 // Seconds

    /**
     * Tests an automatic reconnection.
     * Simulates a connection error and then waits until gets reconnected.
     */
    @TestCase
    public func testAutomaticReconnection(): Unit {
        var connection: XMPPTCPConnection = getConnection(0)
        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPConnectionTestListener(latch)
        connection.addConnectionListener(listener)

        // Simulates an error in the connection
        connection.notifyConnectionError(Exception("Simulated Error"))
        latch.await(MIN_RECONNECT_WAIT, TimeUnit.SECONDS)

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
        // Create the configuration for this connection
        var config: ConnectionConfiguration = ConnectionConfiguration(getHost(), getPort())
        config.setCompressionEnabled(true)
        config.setSASLAuthenticationEnabled(true)

        var connection: XMPPTCPConnection = XMPPConnection(config)
        // Connect to the server
        connection.connect()
        // Log into the server
        connection.login(getUsername(0), getPassword(0), "MyOtherResource")

        assertTrue("Failed to use compression", connection.isUsingCompression())

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)

        var latch: SyncCounter = SyncCounter(1)
        var listener: XMPPTCPConnectionTestListener = XMPPConnectionTestListener(latch)
        connection.addConnectionListener(listener)

        // Simulates an error in the connection
        connection.notifyConnectionError(Exception("Simulated Error"))
        latch.await(MIN_RECONNECT_WAIT, TimeUnit.SECONDS)

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
        var connection: XMPPTCPConnection = getConnection(0)
        var latch: SyncCounter = CountDownLatch(1)
        var listener: XMPPTCPConnectionTestListener = XMPPConnectionTestListener(latch)
        connection.addConnectionListener(listener)

        // Produces a connection error
        connection.notifyConnectionError(Exception("Simulated Error"))
        assertEquals("An error occurs but the ConnectionListener.connectionClosedOnError(e) was not notified", true,
            listener.connectionClosedOnError)
        //        Thread.sleep(1000)

        // Cancels the automatic reconnection
        connection.getConfiguration().setReconnectionAllowed(false)
        // Waits for a reconnection that must not happened.
        sleep(MIN_RECONNECT_WAIT * Duration.second)
        // Cancels the automatic reconnection
        assertEquals(false, listener.reconnected)

        // Makes a manual reconnection from an error terminated connection without reconnection
        connection.connect()

        // Executes some server interaction testing the connection
        executeSomeServerInteraction(connection)
    }

    /**
     * Tests a manual reconnection after a login.
     * Closes the connection and then reconnects.
     */
    @TestCase
    public func testCloseAndManualReconnection(): Unit {
        var connection: XMPPTCPConnection = getConnection(0)
        var username: String = connection.getConfiguration().getUsername()
        var password: String = connection.getConfiguration().getPassword()
        var listener: XMPPTCPConnectionTestListener = XMPPConnectionTestListener()
        connection.addConnectionListener(listener)

        // Produces a normal disconnection
        connection.disconnect()
        assertEquals("ConnectionListener.connectionClosed() was not notified", true, listener.connectionClosed)
        // Waits 10 seconds waiting for a reconnection that must not happened.
        sleep(MIN_RECONNECT_WAIT * Duration.second)
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
        var connection: XMPPTCPConnection = createConnection()
        connection.connect()
        var listener: XMPPTCPConnectionTestListener = XMPPConnectionTestListener()
        connection.addConnectionListener(listener)

        // Makes the anounymous login
        connection.loginAnonymously()

        // Produces a normal disconnection
        connection.disconnect()
        assertEquals("ConnectionListener.connectionClosed() was not notified", true, listener.connectionClosed)
        // Makes a manual reconnection
        connection.connect()
        connection.loginAnonymously()
        assertEquals("Failed the manual connection", true, connection.isAnonymous())
    }

    private func createXMPPConnection(): XMPPTCPConnection {
        var connection: XMPPTCPConnection
        // Create the configuration
        var config: ConnectionConfiguration = ConnectionConfiguration(getHost(), getPort())
        config.setCompressionEnabled(Boolean.getBoolean("test.compressionEnabled"))
        config.setSASLAuthenticationEnabled(true)
        connection = XMPPTCPConnection(config)

        return connection
    }

    /**
     * Execute some server interaction in order to test that the regenerated connection works fine.
     */
    private func executeSomeServerInteraction(connection: TCPConnection): Unit {
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
    private var connectionClosed = false
    private var connectionClosedOnError = false
    private var reconnected = false
    private var reconnectionFailed = false
    private var remainingSeconds = 0
    private var attemptsNotifications = 0
    private var reconnectionCanceled = false
    private var countDownLatch: SyncCounter

    private XMPPTCPConnectionTestListener(latch: SyncCounter) {
        countDownLatch = latch
    }

    private XMPPTCPConnectionTestListener() {
    }
    /**
     * Methods to test the listener.
     */
    public func connectionClosed(): Unit {
        connectionClosed = true

        if (countDownLatch != null) {
            countDownLatch.countDown()
        }
    }

    public func connectionClosedOnError(e: Exception): Unit {
        connectionClosedOnError = true
    }

    public func reconnectionCanceled(): Unit {
        reconnectionCanceled = true

        if (countDownLatch != null) {
            countDownLatch.countDown()
        }
    }

    public func reconnectingIn(seconds: Int): Unit {
        attemptsNotifications = attemptsNotifications + 1
        remainingSeconds = seconds
    }

    public func reconnectionSuccessful(): Unit {
        reconnected = true

        if (countDownLatch != null) {
            countDownLatch.countDown()
        }
    }

    public func reconnectionFailed(error: Exception): Unit {
        reconnectionFailed = true

        if (countDownLatch != null) {
            countDownLatch.countDown()
        }
    }
}
