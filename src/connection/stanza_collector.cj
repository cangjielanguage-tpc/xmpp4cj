/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * Provides a mechanism to collect Stanzas into a result queue that pass a
 * specified filter/matcher. The collector lets you perform blocking and polling
 * operations on the result queue. So, a StanzaCollector is more suitable to
 * use than a {@link StanzaListener} when you need to wait for a specific
 * result.<p>
 *
 * Each stanza collector will queue up a configured number of packets for processing before
 * older packets are automatically dropped.  The default number is retrieved by
 * {@link XmppConfiguration#getStanzaCollectorSize()}.
 *
 * @see XMPPConnection#createStanzaCollector(StanzaFilter)
 */
public class StanzaCollector <: Resource & ToString {
    static let mtx: Monitor = Monitor()

    private let packetFilter: ?StanzaFilter

    private let resultQueue: ArrayList<Stanza>

    private let maxQueueSize: Int64

    private let collectorToReset: ?StanzaCollector

    private let connection: XMPPConnection

    private let request: ?Stanza

    private let cancelled = AtomicBool(false)

    private var connectionException: ?Exception = None

    private var collectedCache: ?ArrayList<Stanza> = None

    private var waitStart: DateTime = DateTime.now()

    private var stringCache: ?String = None

    init(connection: XMPPConnection, configuration: StanzaCollectorConfiguration) {
        this.connection = connection
        this.packetFilter = configuration.packetFilter
        this.resultQueue = ArrayList<Stanza>(configuration.size)
        this.maxQueueSize = configuration.size
        this.collectorToReset = configuration.collectorToReset
        this.request = configuration.request
    }

    /**
     * Explicitly cancels the stanza collector so that no more results are
     * queued up. Once a stanza collector has been cancelled, it cannot be
     * re-enabled. Instead, a new stanza collector must be created.
     */
    public func cancel(): Unit {
        synchronized(mtx) {
            if (isClosed()) {
                return
            }
            cancelled.store(true)
            connection.removeStanzaCollector(this)
            mtx.notifyAll()
            if (let Some(v) <- collectorToReset) {
                v.cancel()
            }
        }
    }

    /**
     * Returns the stanza filter associated with this stanza collector. The stanza
     * filter is used to determine what stanzas are queued as results.
     *
     * @return the stanza filter.
     */
    public func getStanzaFilter(): ?StanzaFilter {
        return packetFilter
    }

    /**
     * Polls to see if a stanza is currently available and returns it, or
     * immediately returns <code>null</code> if no packets are currently in the
     * result queue.
     *
     * @param <P> type of the result stanza.
     * @return the next stanza result, or <code>null</code> if there are no more
     *      results.
     */
    public func pollResult(): ?Stanza {
        synchronized(mtx) {
            let stanza: ?Stanza = resultQueue.get(0)
            if (stanza.isSome()) {
                resultQueue.remove(at: 0)
            }
            return stanza
        }
    }

    /**
     * Polls to see if a stanza is currently available and returns it, or
     * immediately returns <code>null</code> if no packets are currently in the
     * result queue.
     * <p>
     * Throws an XMPPErrorException in case the polled stanzas did contain an XMPPError.
     * </p>
     *
     * @param <P> type of the result stanza.
     * @return the next available packet.
     * @throws XMPPErrorException in case an error response.
     */
    public func pollResultOrThrow(): ?Stanza {
        // TODO
        let result: ?Stanza = pollResult()
        if (let Some(v) <- result) {
            // XMPPErrorException.ifHasErrorThenThrow(v)
        }
        return result
    }

    /**
     * Returns the next available packet. The method call will block until the connection's default
     * timeout has elapsed.
     *
     * @param <P> type of the result stanza.
     * @return the next available packet.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    public func nextResultBlockForever(): ?Stanza {
        synchronized(mtx) {
            throwIfCancelled()
            while (true) {
                let res: ?Stanza = resultQueue.get(0)
                if (res.isSome()) {
                    resultQueue.remove(at: 0)
                }
                if (let Some(v) <- res) {
                    return v
                }
                if (cancelled.load()) {
                    return None
                }
                mtx.wait()
            }
            throw IllegalStateException()
        }
    }

    /**
     * Returns the next available packet. The method call will block until the connection's default
     * timeout has elapsed.
     *
     * @param <P> type of the result stanza.
     * @return the next available packet.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    public func nextResult(): ?Stanza {
        return nextResult(connection.getReplyTimeout())
    }

    /**
     * Returns the next available stanza. The method call will block (not return) until a stanza is available or the
     * <code>timeout</code> has elapsed or if the connection was terminated because of an error. If the timeout elapses without a
     * result or if there was an connection error, <code>null</code> will be returned.
     *
     * @param <P> type of the result stanza.
     * @param timeout the timeout in milliseconds.
     * @return the next available stanza or <code>null</code> on timeout or connection error.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    public func nextResult(timeout: Duration): ?Stanza {
        throwIfCancelled()
        var res: ?Stanza = None
        var remainingWait: Duration = timeout

        var duration: Duration = Duration.Max
        waitStart = DateTime.now()
        while (remainingWait > Duration.Zero && connectionException.isNone() && !cancelled.load()) {
            synchronized(mtx) {
                res = resultQueue.get(0)
                if (res.isSome()) {
                    resultQueue.remove(at: 0)
                }
                if (let Some(v) <- res) {
                    return v
                }
                mtx.wait(timeout: remainingWait)
            }
            remainingWait = timeout - (DateTime.now() - waitStart)
        }
        return res
    }

    /**
     * Returns the next available stanza. The method in equivalent to
     * {@link #nextResultOrThrow(long)} where the timeout argument is the default reply timeout of
     * the connection associated with this collector.
     *
     * @param <P> type of the result stanza.
     * @return the next available stanza.
     * @throws XMPPErrorException in case an error response was received.
     * @throws NoResponseException if there was no response from the server.
     * @throws InterruptedException if the calling thread was interrupted.
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @see #nextResultOrThrow(long)
     */
    public func nextResultOrThrow(): Stanza {
        return nextResultOrThrow(connection.getReplyTimeout())
    }

    /**
     * Returns the next available stanza. The method call will block until a stanza is
     * available or the <code>timeout</code> has elapsed. This method does also cancel the
     * collector in every case.
     * <p>
     * Three things can happen when waiting for an response:
     * </p>
     * <ol>
     * <li>A result response arrives.</li>
     * <li>An error response arrives.</li>
     * <li>An timeout occurs.</li>
     * <li>The thread is interrupted</li>
     * </ol>
     * <p>
     * in which this method will
     * </p>
     * <ol>
     * <li>return with the result.</li>
     * <li>throw an {@link XMPPErrorException}.</li>
     * <li>throw an {@link NoResponseException}.</li>
     * <li>throw an {@link InterruptedException}.</li>
     * </ol>
     * <p>
     * Additionally the method will throw a {@link NotConnectedException} if no response was
     * received and the connection got disconnected.
     * </p>
     *
     * @param timeout the amount of time to wait for the next stanza in milliseconds.
     * @param <P> type of the result stanza.
     * @return the next available stanza.
     * @throws NoResponseException if there was no response from the server.
     * @throws XMPPErrorException in case an error response was received.
     * @throws InterruptedException if the calling thread was interrupted.
     * @throws NotConnectedException if there was no response and the connection got disconnected.
     */
    public func nextResultOrThrow(timeout: Duration): Stanza {
        var result: ?Stanza = None
        try {
            result = nextResult(timeout)
        } finally {
            cancel()
        }
        if (result.isNone()) {
            if (let Some(v) <- connectionException) {
                throw NotConnectedException(connection, packetFilter, v)
            }
            if (!connection.isConnected()) {
                throw NotConnectedException(connection, packetFilter)
            }
            throw NoResponseException.newWith(timeout, this, cancelled.load())
        }
        XMPPErrorException.ifHasErrorThenThrow(result())
        return result.getOrThrow()
    }

    /**
     * Return a list of all collected stanzas. This method must be invoked after the collector has been cancelled.
     *
     * @return a list of collected stanzas.
     */
    public func getCollectedStanzasAfterCancelled(): ArrayList<Stanza> {
        if (!cancelled.load()) {
            throw IllegalStateException("Stanza collector was not yet cancelled")
        }
        if (collectedCache.isNone()) {
            collectedCache = ArrayList<Stanza>(getCollectedCount())
            collectedCache?.add(all: resultQueue)
        }
        return collectedCache()
    }

    /**
     * Get the number of collected stanzas this stanza collector has collected so far.
     *
     * @return the count of collected stanzas.
     */
    public func getCollectedCount(): Int64 {
        synchronized(mtx) {
            return resultQueue.size
        }
    }

    public override func toString(): String {
        if (stringCache.isNone()) {
            let sb = StringBuilder(128)
            sb.append("Stanza Collector filter=\'")
            sb.append(packetFilter.toString())
            sb.append(r'\'')
            if (let Some(v) <- request) {
                sb.append(" request='")
                sb.append(v.toXML())
                sb.append('\'')
            }
            stringCache = sb.toString()
        }
        return stringCache()
    }

    func notifyConnectionError(exception: Exception): Unit {
        synchronized(mtx) {
            connectionException = exception
            mtx.notifyAll()
        }
    }

    /**
     * Processes a stanza to see if it meets the criteria for this stanza collector.
     * If so, the stanza is added to the result queue.
     *
     * @param packet the stanza to process.
     */
    protected func processStanza(packet: Stanza): Unit {
        if (packetFilter.isNone()) {
            processStanzas(packet)
        } else if (let Some(v) <- packetFilter) {
            if (v.accept(packet)) {
                processStanzas(packet)
            }
        }
    }

    private func processStanzas(packet: Stanza): Unit {
        synchronized(mtx) {
            if (resultQueue.size == maxQueueSize) {
                let rolledOverStanza: ?Stanza = resultQueue.get(0)
                if (rolledOverStanza.isSome()) {
                    resultQueue.remove(at: 0)
                }
                assert(rolledOverStanza.isSome())
            }
            resultQueue.add(packet)
            mtx.notifyAll()
        }
        if (let Some(v) <- collectorToReset) {
            v.waitStart = DateTime.now()
        }
    }

    private func throwIfCancelled(): Unit {
        if (cancelled.load()) {
            throw IllegalStateException("Stanza collector already cancelled")
        }
    }

    /**
     * Get a new stanza collector configuration instance.
     *
     * @return a new stanza collector configuration.
     */
    public static func newConfiguration(): StanzaCollectorConfiguration {
        return StanzaCollectorConfiguration()
    }

    public override func close(): Unit {
        cancel()
    }

    public override func isClosed(): Bool {
        cancelled.load()
    }
}

public class StanzaCollectorConfiguration {
    var packetFilter: ?StanzaFilter = None

    var size = XmppConfiguration.getStanzaCollectorSize()

    var collectorToReset: ?StanzaCollector = None

    var request: ?Stanza = None

    init() {
    }

    /**
     * Set the stanza filter used by this collector. If <code>null</code>, then all stanzas will
     * get collected by this collector.
     *
     * @param stanzaFilter
     * @return a reference to this configuration.
     */
    public func setStanzaFilter(stanzaFilter: StanzaFilter): StanzaCollectorConfiguration {
        this.packetFilter = stanzaFilter
        return this
    }

    /**
     * Set the maximum size of this collector, i.e. how many stanzas this collector will collect
     * before dropping old ones.
     *
     * @param size
     * @return a reference to this configuration.
     */
    public func setSize(size: Int64): StanzaCollectorConfiguration {
        this.size = size
        return this
    }

    /**
     * Set the collector which timeout for the next result is reset once this collector collects
     * a packet.
     *
     * @param collector
     * @return a reference to this configuration.
     */
    public func setCollectorToReset(collector: StanzaCollector): StanzaCollectorConfiguration {
        this.collectorToReset = collector
        return this
    }

    public func setRequest(request: Stanza): StanzaCollectorConfiguration {
        this.request = request
        return this
    }
}
