/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

/**
 * Handles the automatic reconnection process. Every time a connection is dropped without
 * the application explicitly closing it, the manager automatically tries to reconnect to
 * the server.<p>
 *
 * There are two possible reconnection policies:
 *
 * {@link ReconnectionPolicy#RANDOM_INCREASING_DELAY} - The reconnection mechanism will try to reconnect periodically:
 * <ol>
 * <li>For the first minute it will attempt to connect once every ten seconds.
 * <li>For the next five minutes it will attempt to connect once a minute.
 * <li>If that fails it will indefinitely try to connect once every five minutes.
 * </ol>
 *
 * {@link ReconnectionPolicy#FIXED_DELAY} - The reconnection mechanism will try to reconnect after a fixed delay
 * independently from the number of reconnection attempts already performed.
 * <p>
 * Interrupting the reconnection thread will abort the reconnection mechanism.
 * </p>
 */
public class ReconnectionManager {
    static let LOGGER = getGlobalLogger("ReconnectionManager")

    private static let INSTANCES: SimpleHashMap<AbstractXMPPConnection, ReconnectionManager> = SimpleHashMap()
    private static let staticLock = Monitor()
    static init() {
        XMPPConnectionRegistry.addConnectionCreationListener(
            ConnectionCreationListener {
                connection => if (let Some(connection) <- (connection as AbstractXMPPConnection)) {
                    ReconnectionManager.getInstanceFor(connection)
                }
            })
    }

    private let lock = Monitor()

    /**
     * Get a instance of ReconnectionManager for the given connection.
     *
     * @param connection XMPP connection
     * @return a ReconnectionManager for the connection.
     */
    public static func getInstanceFor(connection: AbstractXMPPConnection): ReconnectionManager {
        synchronized(staticLock) {
            let reconnectionManager = INSTANCES.get(connection) ??
                {
                =>
                let rcm = ReconnectionManager(connection)
                rcm.reconnectionRunnable = ReconnectionRunnable(rcm).run
                // If the reconnection mechanism is enable per default, enable it for this ReconnectionManager instance
                if (getEnabledPerDefault()) {
                    rcm.enableAutomaticReconnection()
                }

                let connListener = RCMConnectionListener(rcm)
                rcm.connectionListener = connListener

                INSTANCES.put(connection, rcm)
                rcm
            }()
            return reconnectionManager
        }
    }

    private static var enabledPerDefault = false

    /**
     * Set if the automatic reconnection mechanism will be enabled per default for new XMPP connections.
     * The default is 'false'.
     *
     * @param enabled 是否启用
     */
    public static func setEnabledPerDefault(enabled: Bool): Unit {
        enabledPerDefault = enabled
    }

    /**
     * Get the current default reconnection mechanism setting for new XMPP connections.
     *
     * @return true if new connection will come with an enabled reconnection mechanism
     */
    public static func getEnabledPerDefault(): Bool {
        return enabledPerDefault
    }

    let reconnectionListeners: ConcurrentSet<ReconnectionListener> = ConcurrentSet()

    let weakRefConnection: AbstractXMPPConnection
    let randomBase = Duration.second * (Random().nextInt64(13) + 2) // between 2 and 15 seconds
    private var reconnectionRunnable: Runnable = {=>}

    private static var defaultFixedDelay = Duration.second * 15
    private static var defaultReconnectionPolicy: ReconnectionPolicy = ReconnectionPolicy.RANDOM_INCREASING_DELAY

    var fixedDelay = defaultFixedDelay
    var reconnectionPolicy = defaultReconnectionPolicy

    /**
     * Set the default fixed delay in seconds between the reconnection attempts. Also set the
     * default connection policy to {@link ReconnectionPolicy#FIXED_DELAY}
     *
     * @param fixedDelay Delay expressed in seconds
     */
    public static func setDefaultFixedDelay(fixedDelay: Duration): Unit {
        defaultFixedDelay = fixedDelay
        setDefaultReconnectionPolicy(ReconnectionPolicy.FIXED_DELAY)
    }

    /**
     * Set the default Reconnection Policy to use.
     *
     * @param reconnectionPolicy 重连的延迟时间策略
     */
    public static func setDefaultReconnectionPolicy(reconnectionPolicy: ReconnectionPolicy): Unit {
        defaultReconnectionPolicy = reconnectionPolicy
    }

    /**
     * Add a new reconnection listener.
     *
     * @param listener the listener to add
     * @return <code>true</code> if the listener was not already added
     */
    public func addReconnectionListener(listener: ReconnectionListener): Bool {
        return reconnectionListeners.put(listener)
    }

    /**
     * Remove a reconnection listener.
     * @param listener the listener to remove
     * @return <code>true</code> if the listener was active and got removed.
     */
    public func removeReconnectionListener(listener: ReconnectionListener): Bool {
        return reconnectionListeners.remove(listener)
    }

    /**
     * Set the fixed delay in seconds between the reconnection attempts Also set the connection
     * policy to {@link ReconnectionPolicy#FIXED_DELAY}.
     *
     * @param fixedDelay Delay expressed in seconds
     */
    public func setFixedDelay(fixedDelay: Duration): Unit {
        this.fixedDelay = fixedDelay
        setReconnectionPolicy(ReconnectionPolicy.FIXED_DELAY)
    }

    /**
     * Set the Reconnection Policy to use.
     *
     * @param reconnectionPolicy 重连的延迟时间策略
     */
    public func setReconnectionPolicy(reconnectionPolicy: ReconnectionPolicy): Unit {
        this.reconnectionPolicy = reconnectionPolicy
    }

    /**
     * Flag that indicates if a reconnection should be attempted when abruptly disconnected.
     */
    private var automaticReconnectEnabled = false

    var done = false

    private var reconnectionThread: ?Future<Unit> = None

    private init(connection: AbstractXMPPConnection) {
        weakRefConnection = connection
        connectionListener = RCMConnectionListener(this)
        // If the reconnection mechanism is enable per default, enable it for this ReconnectionManager instance
        if (getEnabledPerDefault()) {
            enableAutomaticReconnection()
        }
    }

    /**
     * Enable the automatic reconnection mechanism. Does nothing if already enabled.
     */
    public func enableAutomaticReconnection(): Unit {
        synchronized(lock) {
            if (automaticReconnectEnabled) {
                return
            }
            let connection = weakRefConnection
            connection.addConnectionListener(connectionListener)
            automaticReconnectEnabled = true
        }
    }

    /**
     * Disable the automatic reconnection mechanism. Does nothing if already disabled.
     */
    public func disableAutomaticReconnection(): Unit {
        synchronized(lock) {
            if (!automaticReconnectEnabled) {
                return
            }
            let connection = weakRefConnection as AbstractXMPPConnection
            if (connection.isNone()) {
                throw IllegalStateException("Connection instance no longer available")
            }
            connection?.removeConnectionListener(connectionListener)
            automaticReconnectEnabled = false
        }
    }

    /**
     * Returns if the automatic reconnection mechanism is enabled. You can disable the reconnection mechanism with
     * {@link #disableAutomaticReconnection} and enable the mechanism with {@link #enableAutomaticReconnection()}.
     *
     * @return true, if the reconnection mechanism is enabled.
     */
    public func isAutomaticReconnectEnabled(): Bool {
        synchronized(lock) {
            return automaticReconnectEnabled
        }
    }

    /**
     * Returns true if the reconnection mechanism is enabled.
     *
     * @return true if automatic reconnection is allowed.
     */
    func isReconnectionPossible(connection: XMPPConnection): Bool {
        return !done && !connection.isConnected() && isAutomaticReconnectEnabled()
    }

    /**
     * Starts a reconnection mechanism if it was configured to do that.
     * The algorithm is been executed when the first connection error is detected.
     */
    func reconnect(): Unit {
        synchronized(lock) {
            let connection = this.weakRefConnection as AbstractXMPPConnection
            if (connection.isNone()) {
                LOGGER.trace("Connection is null, will not reconnect")
                return
            }
            if (reconnectionThread.isSome() && !reconnectionThread().thread.hasPendingCancellation) {
                return
            }
            reconnectionThread = Async.go(
                reconnectionRunnable,
                "Xmpp Reconnection Manager (${connection().getConnectionCounter()})"
            )
        }
    }

    /**
     * Abort a possibly running reconnection mechanism.
     */
    public func abortPossiblyRunningReconnection(): Unit {
        synchronized(lock) {
            if (reconnectionThread.isNone()) {
                return
            }
            reconnectionThread?.cancel()
            reconnectionThread = None
        }
    }

    private var connectionListener: ConnectionListener = unsafe { zeroValue<ConnectionListener>() } // 占位 已在init中初始化
}

class ReconnectionRunnable {
    let this_0: ReconnectionManager
    init(this_0: ReconnectionManager) {
        this.this_0 = this_0
    }

    /**
     * Holds the current number of reconnection attempts
     */
    private var attempts = 0

    /**
     * Returns the number of seconds until the next reconnection attempt.
     *
     * @return the number of seconds until the next reconnection attempt.
     */
    private func timeDelay(): Duration {
        attempts++
        let delay: Duration = match (this_0.reconnectionPolicy) {
            case FIXED_DELAY => this_0.fixedDelay
            case RANDOM_INCREASING_DELAY =>
                if (attempts > 13) {
                    this_0.randomBase * 6 * 5 // between 2.5 and 7.5 minutes (~5 minutes)
                } else if (attempts > 7) {
                    this_0.randomBase * 6 // between 30 and 90 seconds (~1 minutes)
                } else {
                    this_0.randomBase // 10 seconds
                }
        }

        return delay
    }

    /**
     * The process will try the reconnection until the connection succeed or the user cancel it
     */
    public func run(): Unit {
        let connection = this_0.weakRefConnection
        attempts = 0
        while (this_0.isReconnectionPossible(connection)) {
            var remainingSeconds = timeDelay()
            while (remainingSeconds > Duration.Zero) {
                if (!this_0.isReconnectionPossible(connection)) {
                    return
                }
                if (Thread.currentThread.hasPendingCancellation) {
                    ReconnectionManager
                        .LOGGER
                        .log(LogLevel.TRACE, "Reconnection Thread was interrupted, aborting reconnection mechanism")
                    return
                }
                sleep(Duration.second)
                remainingSeconds -= Duration.second
                for (listener in this_0.reconnectionListeners) {
                    listener.reconnectingIn(remainingSeconds)
                }
            }
            for (listener in this_0.reconnectionListeners) {
                listener.reconnectingIn(Duration.Zero)
            }
            if (!this_0.isReconnectionPossible(connection)) {
                return
            }
            try {
                try {
                    connection.connect()
                } catch (e: AlreadyConnectedException) {
                    ReconnectionManager
                        .LOGGER
                        .log(LogLevel.TRACE, "Connection was already connected on reconnection attempt", e)
                }
                connection.login()
            } catch (e: AlreadyLoggedInException) {
                ReconnectionManager.LOGGER.log(LogLevel.TRACE, "Reconnection not required, was already logged in", e)
            } catch (e: Xmpp4cjException | IOException | XMPPException) {
                for (listener in this_0.reconnectionListeners) {
                    listener.reconnectionFailed(e)
                }
                continue
            } catch (e: Exception) {
                ReconnectionManager
                    .LOGGER
                    .log(LogLevel.TRACE, "Reconnection Thread was interrupted, aborting reconnection mechanism", e)
                return
            }
            return
        }
    }
}

class RCMConnectionListener <: ConnectionListener {
    let this_0: ReconnectionManager
    init(this_0: ReconnectionManager) {
        this.this_0 = this_0
    }

    public override func connectionClosed(): Unit {
        this_0.done = true
    }

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {
        this_0.done = false
    }

    public override func connectionClosedOnError(e: Exception): Unit {
        this_0.done = false
        if (!this_0.isAutomaticReconnectEnabled()) {
            return
        }
        if (let Some(xmppEx) <- (e as StreamErrorException)) {
            let error = xmppEx.getStreamError()
            if (error.getCondition() == StreamErrorCondition.conflict) {
                return
            }
        }
        this_0.reconnect()
    }
}

/**
 * Reconnection Policy, where {@link ReconnectionPolicy#RANDOM_INCREASING_DELAY} is the default policy used by xmpp and {@link ReconnectionPolicy#FIXED_DELAY} implies
 * a fixed amount of time between reconnection attempts.
 */
public enum ReconnectionPolicy <: ToString {
    /**
     * Default policy classically used by xmpp, having an increasing delay related to the
     * overall number of attempts.
     */
    RANDOM_INCREASING_DELAY

    /**
     * Policy using fixed amount of time between reconnection attempts.
     */
    | FIXED_DELAY

    public override func toString(): String {
        match (this) {
            case RANDOM_INCREASING_DELAY => "RANDOM_INCREASING_DELAY"
            case FIXED_DELAY => "FIXED_DELAY"
        }
    }
}
