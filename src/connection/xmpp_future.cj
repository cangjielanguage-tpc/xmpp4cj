/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

public abstract class XmppFuture<V, E> <: CallbackRecipient<V, E> where E <: Exception {
    static let LOGGER = getGlobalLogger(("name", "XmppFuture"))
    protected let lock: Monitor = Monitor()

    private var cancelled = false
    private var callbacksInvoked: Bool = false

    protected var result: ?V = None
    protected var exception: ?E = None

    private var successCallback: ?SuccessCallback<V> = None
    private var exceptionCallback: ?ExceptionCallback<E> = None
    private var completionCallback: ?Consumer<XmppFuture<V, E>> = None

    public func cancel(mayInterruptIfRunning: Bool): Bool {
        synchronized(lock) {
            if (isDone()) {
                return false
            }
            cancelled = true
            if (mayInterruptIfRunning) {
                lock.notifyAll()
            }
            return true
        }
    }

    public func isCancelled(): Bool {
        synchronized(lock) {
            return cancelled
        }
    }

    public func isDone(): Bool {
        synchronized(lock) {
            return result.isSome()
        }
    }

    public override func onSuccess(successCallback: SuccessCallback<V>): CallbackRecipient<V, E> {
        this.successCallback = successCallback
        maybeInvokeCallbacks()
        return this
    }

    public override func onError(exceptionCallback: ExceptionCallback<E>): CallbackRecipient<V, E> {
        this.exceptionCallback = exceptionCallback
        maybeInvokeCallbacks()
        return this
    }

    public func onCompletion(completionCallback: Consumer<XmppFuture<V, E>>): Unit {
        this.completionCallback = completionCallback
        maybeInvokeCallbacks()
    }

    private func getOrThrowExecutionException(): V {
        assert(result.isSome() || exception.isSome() || cancelled)
        if (let Some(v) <- result) {
            return v
        }
        if (let Some(v) <- exception) {
            throw ExecutionException(v)
        }
        assert(cancelled)
        throw CancellationException()
    }

    public func get(): V {
        synchronized(lock) {
            while (result.isNone() && exception.isNone() && !cancelled) {
                futureWait()
            }
            return getOrThrowExecutionException()
        }
    }

    public func getOrThrow(): V {
        synchronized(lock) {
            while (result.isNone() && exception.isNone() && !cancelled) {
                futureWait()
            }
            if (let Some(v) <- exception) {
                throw v
            }
            if (cancelled) {
                throw CancellationException()
            }
            assert(result.isSome())
            return result()
        }
    }

    public func get(timeout: Duration): V {
        synchronized(lock) {
            let deadline = DateTime.now() + timeout
            while (result.isSome() && exception.isSome()) {
                let waitTimeRemaining = deadline - DateTime.now()
                if (waitTimeRemaining > Duration.Zero) {
                    futureWait(waitTimeRemaining)
                }
            }
            if (cancelled) {
                throw CancellationException()
            }
            if (result.isNone() || exception.isNone()) {
                throw TimeoutException()
            }
            return getOrThrowExecutionException()
        }
    }

    public func getIfAvailable(): ?V {
        return result
    }

    protected func maybeInvokeCallbacks(): Unit {
        synchronized(lock) {
            if (cancelled || callbacksInvoked) {
                return
            }
            if ((result.isSome() || exception.isSome()) && completionCallback.isSome()) {
                callbacksInvoked = true
                completionCallback?(this)
            }
            if (let (Some(v), Some(vc)) <- (result, successCallback)) {
                callbacksInvoked = true
                AbstractXMPPConnection.asyncGo({=> vc(v)})
            } else if (let (Some(e), Some(ec)) <- (exception, exceptionCallback)) {
                callbacksInvoked = true
                AbstractXMPPConnection.asyncGo({=> ec.processException(e)})
            }
        }
    }

    protected func futureWait(): Unit {
        futureWait(None)
    }

    protected open func futureWait(timeout: ?Duration): Unit {
        let dur = timeout ?? Duration.Zero
        if (dur > Duration.Zero) {
            lock.wait(timeout: dur)
        } else {
            lock.wait()
        }
    }

    public static func comefrom(result: V): XmppFuture<V, Exception> {
        let future: InternalXmppFuture<V, Exception> = InternalXmppFuture<V, Exception>()
        future.setResult(result)
        return future
    }

    public static func await<F, V, E>(
        futures: Collection<F>,
        timeout: Duration
    ): Bool where F <: XmppFuture<V, E>, E <: Exception {
        let latch = SyncCounter(futures.size)
        for (future in futures) {
            future.onCompletion {f => latch.dec()}
        }
        latch.waitUntilZero(timeout: timeout)
        return latch.count == 0
    }
}

public open class InternalXmppFuture<V, E> <: XmppFuture<V, E> where E <: Exception {
    public func setResult(result: V): Unit {
        synchronized(lock) {
            this.result = result
            lock.notifyAll()
            maybeInvokeCallbacks()
        }
    }

    public func setException(exception: E): Unit {
        synchronized(lock) {
            this.exception = exception
            lock.notifyAll()
            maybeInvokeCallbacks()
        }
    }
}

public class SocketFuture <: InternalXmppFuture<TcpSocket, Exception> {
    private var socket: TcpSocket
    // private let socketFactory: SocketFactory
    private let wasInterruptedLock = Monitor()
    private var wasInterrupted: Bool = false

    public init(socketFactory: SocketFactory, addr: IPSocketAddress) {
        this.socket = socketFactory.createSocket(addr)
    }

    protected override func futureWait(timeout: ?Duration): Unit {
        try {
            super.futureWait(timeout)
        } catch (interruptedException: Exception) {
            synchronized(wasInterruptedLock) {
                wasInterrupted = true
                closeSocket()
            }
            throw interruptedException
        }
    }

    public func connectAsync(socketAddress: IPSocketAddress, timeout: Duration): Unit {
        AbstractXMPPConnection.asyncGo(
            {
                =>
                try {
                    socket.connect(timeout: timeout)
                } catch (e: Exception) {
                    setException(e)
                    return
                }
                synchronized(wasInterruptedLock) {
                    if (wasInterrupted) {
                        closeSocket()
                        return
                    }
                }
                setResult(socket)
            }
        )
    }

    public func closeSocket(): Unit {
        try {
            socket.close()
        } catch (ioException: Exception) {
            LOGGER.warn("Could not close socket", ("exception", ioException))
        }
    }
}

public abstract class InternalProcessStanzaXmppFuture<V, E> <: InternalXmppFuture<V, E> & StanzaListener & ExceptionCallback<E> where E <: Exception {
    /**
     * This method checks if the given exception is <b>not</b> fatal. If this method returns <code>false</code>,
     * then the future will automatically set the given exception as failure reason and notify potential waiting
     * threads.
     *
     * @param exception the exception to check.
     * @return <code>true</code> if the exception is not fatal, <code>false</code> otherwise.
     */
    protected func isNonFatalException(exception: E): Bool

    protected func handleStanza(stanza: Stanza): Unit

    public override func processException(exception: E): Unit {
        synchronized(lock) {
            if (!isNonFatalException(exception)) {
                this.exception = exception
                lock.notifyAll()
                maybeInvokeCallbacks()
            }
        }
    }

    /**
     * Wrapper method for {@link #handleStanza(Stanza)}. Note that this method is <code>synchronized</code>.
     */
    public override func processStanza(stanza: Stanza): Unit {
        synchronized(lock) {
            handleStanza(stanza)
        }
    }
}

/**
 * A simple version of InternalXmppFuture which implements isNonFatalException(E) as always returning
 * <code>false</code> method.
 *
 * @param <V> the return value of the future.
 */
public abstract class SimpleInternalProcessStanzaXmppFuture<V, E> <: InternalProcessStanzaXmppFuture<V, E> where E <: Exception {
    protected override func isNonFatalException(exception: E): Bool {
        return false
    }
}

public class ExecutionException <: Exception {
    public ExecutionException(public let cause: Exception) {
        super(cause.message)
    }

    protected override func getClassName(): String {
        "ExecutionException"
    }
}

public class CancellationException <: Exception {
    protected override func getClassName(): String {
        "CancellationException"
    }
}

public class TimeoutException <: Exception {
    protected override func getClassName(): String {
        "TimeoutException"
    }
}
