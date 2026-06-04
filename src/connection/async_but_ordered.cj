package xmpp4cj.connection

/**
 * Helper class to perform an operation asynchronous but keeping the order in respect to a given key.
 * <p>
 * A typical use pattern for this helper class consists of callbacks for an abstract entity where the order of callbacks
 * matters, which eventually call user code in form of listeners. Since the order the callbacks matters, you need to use
 * synchronous connection listeners. But if those listeners would invoke the user provided listeners, and if those user
 * provided listeners would take a long time to complete, or even worse, block, then Xmpp's total progress is stalled,
 * since synchronous connection listeners are invoked from the main event loop.
 * </p>
 * <p>
 * It is common for those situations that the order of callbacks is not globally important, but only important in
 * respect to an particular entity. Take chat state notifications (CSN) for example: Assume there are two contacts which
 * send you CSNs. If a contact sends you first 'active' and then 'inactive, it is crucial that first the listener is
 * called with 'active' and afterwards with 'inactive'. But if there is another contact is sending 'composing' followed
 * by 'paused', then it is also important that the listeners are invoked in the correct order, but the order in which
 * the listeners for those two contacts are invoked does not matter.
 * </p>
 * <p>
 * Using this helper class, one would call {@link #performAsyncButOrdered(Object, Runnable)} which the remote contacts
 * JID as first argument and a {@link Runnable} invoking the user listeners as second. This class guarantees that
 * runnables of subsequent invocations are always executed after the runnables of previous invocations using the same
 * key.
 * </p>
 *
 * @param <K> the type of the key
 */
public class AsyncButOrdered<K> {
    /**
     * A map with the currently pending runnables for a given key. Note that this is a weak hash map so we do not have
     * to take care of removing the keys ourselfs from the map.
     */
    private let pendingRunnables: SimpleHashMap<K, ConcurrentLinkedQueue<Runnable>> = SimpleHashMap()
    private let pendingRunnablesLock = Mutex()

    /**
     * A marker map if there is an active thread for the given key. Holds the responsible handler thread if one is
     * active, otherwise the key is non-existend in the map.
     */
    let threadActiveMap: SimpleHashMap<K, AsyncButOrderedHandler<K>> = SimpleHashMap<K, AsyncButOrderedHandler<K>>()
    let threadActiveMapLock = Mutex()

    private let executor: ?Executor

    public init() {
        this(None)
    }

    public init(executor: ?Executor) {
        this.executor = executor
    }

    func scheduleHandler(handler: AsyncButOrderedHandler<K>): Unit {
        if (let Some(executor) <- executor) {
            executor(handler.run)
        } else {
            AbstractXMPPConnection.asyncGo(handler.run)
        }
    }

    /**
     * Invoke the given {@link Runnable} asynchronous but ordered in respect to the given key.
     *
     * @param key the key deriving the order
     * @param runnable the {@link Runnable} to run
     * @return true if a new thread was created
     */
    public func performAsyncButOrdered(key: K, runnable: Runnable): Bool {
        // First check if a key queue already exists, create one if not.
        let keyQueue: ConcurrentLinkedQueue<Runnable> = synchronized(pendingRunnablesLock) {
            pendingRunnables.get(key) ??
                {
                =>
                let keyQueue = ConcurrentLinkedQueue<Runnable>()
                pendingRunnables.put(key, keyQueue)
                keyQueue
            }()
        }

        // Then add the task to the queue.
        keyQueue.add(runnable)

        // Finally check if there is already a handler working on that queue, create one if not.
        var newlyCreatedHandler: ?AsyncButOrderedHandler<K> = None
        synchronized(threadActiveMapLock) {
            if (!threadActiveMap.contains(key)) {
                newlyCreatedHandler = AsyncButOrderedHandler(this, keyQueue, key)
                threadActiveMap.put(key, newlyCreatedHandler())
            }
        }
        if (let Some(newlyCreatedHandler) <- newlyCreatedHandler) {
            scheduleHandler(newlyCreatedHandler)
            return true
        }
        return false
    }

    public func asExecutorFor(key: K): Executor {
        return {runnable => performAsyncButOrdered(key, runnable)}
    }
}

// type AsyncButOrderedHandler = Runnable
class AsyncButOrderedHandler<K> {
    AsyncButOrderedHandler(let this_0: AsyncButOrdered<K>, let keyQueue: ConcurrentLinkedQueue<Runnable>, let key: K) {}

    public func run(): Unit {
        while (true) {
            while (let Some(runnable) <- keyQueue.remove()) {
                try {
                    runnable()
                } catch (t: Exception) {
                    // The run() method threw, this handler thread is going to terminate because of that.
                    // We create a new handler to continue working on the queue while throwing the throwable
                    // so that the executor can handle it.
                    let newlyCreatedHandler = AsyncButOrderedHandler(this_0, keyQueue, key)
                    synchronized(this_0.threadActiveMapLock) {
                        this_0.threadActiveMap.put(key, newlyCreatedHandler)
                    }
                    this_0.scheduleHandler(newlyCreatedHandler)
                    throw t
                }
            }
            synchronized(this_0.threadActiveMapLock) {
                // If the queue is empty, stop this handler, otherwise continue looping.
                if (keyQueue.size == 0) {
                    this_0.threadActiveMap.remove(key)
                    return
                }
            }
        }
    }
}
