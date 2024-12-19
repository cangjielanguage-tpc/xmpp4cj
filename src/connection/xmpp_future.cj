/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * public abstract class XmppFuture<V, E> <: CallbackRecipient<V, E> where E <: Exception
 *
 * XmppFuture 是一个抽象类，实现了  CallbackRecipient 接口。
 * <p>
 * 该类用于处理异步操作的结果，包括成功结果和异常处理。
 * </p>
 *
 * @param <V> future 返回值的类型
 * @param <E> 异常的类型，必须是 Exception 的子类 */
public abstract class XmppFuture<V, E> <: CallbackRecipient<V, E> where E <: Exception {
    /**
     * 日志
     */
    static let LOGGER = getGlobalLogger(("name", "XmppFuture"))

    /**
     * 锁
     */
    protected let lock: Monitor = Monitor()

    /** 
     * 标记当前任务是否被取消
     */
    private var cancelled = false

    /** 
     * 标记回调是否已被调用
     */
    private var callbacksInvoked: Bool = false

    /** 
     * 成功结果
     */
    protected var result: ?V = None

    /** 
     * 异常信息
     */
    protected var exception: ?E = None

    /** 
     * 成功回调
     */
    private var successCallback: ?SuccessCallback<V> = None

    /** 
     * 异常回调
     */
    private var exceptionCallback: ?ExceptionCallback<E> = None

    /** 
     * 完成回调
     */
    private var completionCallback: ?Consumer<XmppFuture<V, E>> = None

    /**
     * 取消当前任务。
     *
     * @param mayInterruptIfRunning 如果为 <code>true</code>，则在任务正在运行时中断任务
     * @return 如果任务成功取消，则返回 <code>true</code>
     */
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

    /**
     * 检查当前任务是否已被取消。
     *
     * @return 如果任务已取消，则返回 <code>true</code>
     */
    public func isCancelled(): Bool {
        synchronized(lock) {
            return cancelled
        }
    }

    /**
     * 检查当前任务是否已完成。
     *
     * @return 如果任务已完成，则返回 <code>true</code>
     */
    public func isDone(): Bool {
        synchronized(lock) {
            return result.isSome()
        }
    }

    /**
     * 设置成功回调。
     *
     * @param successCallback 成功回调
     * @return 当前对象，以便进行链式调用
     */
    public override func onSuccess(successCallback: SuccessCallback<V>): CallbackRecipient<V, E> {
        this.successCallback = successCallback
        maybeInvokeCallbacks()
        return this
    }

    /**
     * 设置异常回调。
     *
     * @param exceptionCallback 异常回调
     * @return 当前对象，以便进行链式调用
     */
    public override func onError(exceptionCallback: ExceptionCallback<E>): CallbackRecipient<V, E> {
        this.exceptionCallback = exceptionCallback
        maybeInvokeCallbacks()
        return this
    }

    /**
     * 设置完成回调。
     *
     * @param completionCallback 完成回调
     */
    public func onCompletion(completionCallback: Consumer<XmppFuture<V, E>>): Unit {
        this.completionCallback = completionCallback
        maybeInvokeCallbacks()
    }

    /**
     * 获取结果或抛出执行异常。
     *
     * @return结果
     * @throws ExecutionException 如果执行过程中出现异常
     */
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

    /**
     * 获取结果，阻塞直到结果可用。
     *
     * @return结果
     * @throws InterruptedException 如果当前线程被中断
     * @throws ExecutionException 如果执行过程中出现异常
     */
    public func get(): V {
        synchronized(lock) {
            while (result.isNone() && exception.isNone() && !cancelled) {
                futureWait()
            }
            return getOrThrowExecutionException()
        }
    }

    /**
     * 获取结果，抛出异常。
     *
     * @return结果
     * @throws E 如果出现异常
     * @throws InterruptedException 如果当前线程被中断
     */
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

    /**
     * 获取结果，带有超时功能。
     *
     * @param timeout 超时时间
     * @return 结果
     * @throws InterruptedException 如果当前线程被中断
     * @throws ExecutionException 如果执行过程中出现异常
     * @throws TimeoutException 如果超时
     */
    public func get(timeout: Duration): V {
        synchronized(lock) {
            let deadline = DateTime.now() + timeout
            while (result.isNone() && exception.isNone()) {
                let waitTimeRemaining = deadline - DateTime.now()
                if (waitTimeRemaining > Duration.Zero) {
                    futureWait(waitTimeRemaining)
                } else {
                    throw TimeoutException()
                }
            }
            if (cancelled) {
                throw CancellationException()
            }
            return getOrThrowExecutionException()
        }
    }

    /**
     * 获取当前可用的结果。
     *
     * @return 当前可用的结果，如果没有可用结果则返回 <code>null</code>
     */
    public func getIfAvailable(): ?V {
        return result
    }

    /**
     * 可能调用回调函数。
     * <p>
     * 如果任务已取消或回调已被调用，则不再调用回调。
     * </p>
     */
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

    /**
     * 等待直到结果可用。
     *
     * @throws InterruptedException 如果当前线程被中断
     */
    protected func futureWait(): Unit {
        futureWait(None)
    }

    /**
     * 等待直到结果可用，带有超时功能。
     *
     * @param timeout 超时时间（毫秒）
     * @throws InterruptedException 如果当前线程被中断
     */
    protected open func futureWait(timeout: ?Duration): Unit {
        let dur = timeout ?? Duration.Zero
        if (dur > Duration.Zero) {
            lock.wait(timeout: dur)
        } else {
            lock.wait()
        }
    }

    /**
     * 从结果创建 XmppFuture 实例。
     *
     * @param result 结果
     * @return XmppFuture 实例
     */
    public static func comefrom(result: V): XmppFuture<V, Exception> {
        let future: InternalXmppFuture<V, Exception> = InternalXmppFuture<V, Exception>()
        future.setResult(result)
        return future
    }

    /**
     * 等待一组 XmppFuture 完成。
     *
     * @param futures需要等待的 XmppFuture 集合
     * @param timeout 等待的最大时间
     * @return 如果所有任务在指定时间内完成，则返回 <code>true</code>；否则返回 <code>false</code>
     * @throws InterruptedException 如果当前线程被中断
     */
    public static func await<V1>(
        futures: Collection<XmppFuture<V1, Exception>>,
        timeout: Duration
    ): Bool {
        let latch = SyncCounter(futures.size)
        for (future in futures) {
            future.onCompletion {_ => latch.dec()}
        }
        latch.waitUntilZero(timeout: timeout)
        return latch.count == 0
    }
}

/**
 * InternalXmppFuture 是一个内部类，扩展了 XmppFuture，用于处理异步操作的结果。
 * <p>
 * 该类提供了设置结果或异常的功能，并在这些状态变化时通知所有等待的线程。
 * </p>
 *
 * @param <V>结果的类型
 * @param <E> 异常的类型，必须是 Exception 的子类
 */
public open class InternalXmppFuture<V, E> <: XmppFuture<V, E> where E <: Exception {
    /**
     * 设置异步操作的结果。
     * <p>
     * 在设置结果后，通知所有等待的线程，并可能调用注册的回调函数。
     * </p>
     *
     * @param result 异步操作的结果
     */
    public func setResult(result: V): Unit {
        synchronized(lock) {
            this.result = result
            lock.notifyAll()
            maybeInvokeCallbacks()
        }
    }

    /**
     * 设置异步操作出现的异常。
     * <p>
     * 在设置异常后，通知所有等待的线程，并可能调用注册的回调函数。
     * </p>
     *
     * @param exception 异步操作中出现的异常
     */
    public func setException(exception: E): Unit {
        synchronized(lock) {
            this.exception = exception
            lock.notifyAll()
            maybeInvokeCallbacks()
        }
    }
}

/**
 * SocketFuture 类扩展了 InternalXmppFuture，用于处理异步 Socket连接的结果。
 * <p>
 * 此类负责创建 Socket，并提供异步连接的功能，同时处理连接过程中的中断和异常。
 * </p>
 */
public class SocketFuture <: InternalXmppFuture<TcpSocket, Exception> {
    /**
     * 关联的 Socket 对象
     */
    private var socket: TcpSocket

    /**
     * 用于同步的锁对象，检查是否被中断
     */
    // private let socketFactory: SocketFactory

    /** 
     * 锁
     */
    private let wasInterruptedLock = Monitor()

    /** 
     * 标记是否被中断
     */
    private var wasInterrupted: Bool = false

    /**
     * 构造函数，使用指定的 SocketFactory 创建 Socket。
     *
     * @param socketFactory 用于创建 Socket 的工厂
     * @throws IOException 如果创建 Socket过程中发生错误
     */
    public init(socketFactory: SocketFactory, addr: IPSocketAddress) {
        this.socket = socketFactory.createSocket(addr)
    }

    /**
     * 等待异步操作的结果，带有超时功能。
     * <p>
     * 如果在等待过程中被中断，则关闭 Socket（如果尚未关闭），并抛出 InterruptedException。
     * </p>
     *
     * @param timeout 等待的超时时间（毫秒）
     * @throws InterruptedException 如果当前线程在等待过程中被中断
     */
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

    /**
     * 异步连接到指定的 Socket 地址。
     *
     * @param socketAddress目标 Socket 地址 * @param timeout连接超时时间（毫秒）
     */
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

    /**
     * 关闭 Socket连接。
     * <p>
     * 如果关闭过程中发生 IOException，将记录警告日志。
     * </p>
     */
    public func closeSocket(): Unit {
        try {
            socket.close()
        } catch (ioException: Exception) {
            LOGGER.warn("Could not close socket", ("exception", ioException))
        }
    }
}

/**
 * public abstract class InternalProcessStanzaXmppFuture<V, E> <: InternalXmppFuture<V, E> & StanzaListener & ExceptionCallback<E> where E <: Exception
 *
 * InternalProcessStanzaXmppFuture 是一个抽象类，扩展了 InternalXmppFuture，
 * 同时实现了 StanzaListener 和 ExceptionCallback 接口。
 * <p>
 * 该类用于处理 Xmpp相关的异步操作结果，并在出现异常时进行处理。
 * </p>
 *
 * @param <V>结果的类型 * @param <E> 异常的类型，必须是 Exception 的子类
 */
public abstract class InternalProcessStanzaXmppFuture<V, E> <: InternalXmppFuture<V, E> & StanzaListener & ExceptionCallback<E> where E <: Exception {
    /**
     * 检查给定的异常是否为非致命异常。
     * <p>
     * 如果此方法返回 <code>false</code>，则将自动将给定的异常设置为失败原因，并通知所有等待的线程。
     * </p>
     *
     * @param exception 要检查的异常
     * @return 如果异常不是致命的，则返回 <code>true</code>，否则返回 <code>false</code>
     */
    protected func isNonFatalException(exception: E): Bool

    /**
     * 处理接收到的 Stanza。
     *
     * @param stanza 接收到的 Stanza 对象
     */
    protected func handleStanza(stanza: Stanza): Unit

    /**
     * 处理异常的方法。
     * <p>
     * 如果捕获到的异常不是非致命异常，则设置此异常并通知所有等待的线程。
     * </p>
     *
     * @param exception 捕获到的异常
     */
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
     * 处理 Stanza 的封装方法。
     * <p>
     * 请注意，此方法是 <code>synchronized</code> 的。
     * </p>
     *
     * @param stanza 要处理的 Stanza 对象
     */
    public override func processStanza(stanza: Stanza): Unit {
        synchronized(lock) {
            handleStanza(stanza)
        }
    }
}

/**
 * public abstract class SimpleInternalProcessStanzaXmppFuture<V, E> <: InternalProcessStanzaXmppFuture<V, E> where E <: Exception
 *
 * SimpleInternalProcessStanzaXmppFuture 类是 InternalProcessStanzaXmppFuture 的简单实现，
 * 其 isNonFatalException(E) 方法始终返回 <code>false</code>。
 * <p>
 * 该类的实例在处理异常时将始终视所有异常为致命异常。
 * </p>
 *
 * @param <V> future 返回值的类型
 * @param <E> 异常的类型，必须是 Exception 的子类 */
public abstract class SimpleInternalProcessStanzaXmppFuture<V, E> <: InternalProcessStanzaXmppFuture<V, E> where E <: Exception {
    /**
     * 始终返回 <code>false</code>，表示捕获到的异常被视为致命异常。
     *
     * @param exception 要检查的异常
     * @return 始终返回 <code>false</code>
     */
    protected override func isNonFatalException(exception: E): Bool {
        return false
    }
}

public class ExecutionException <: ExceptionExt {
    /**
     * 通过Exception初始化ExecutionException。
     *
     * @param cause Exception
     */
    public init(cause: Exception) {
        super(cause)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "ExecutionException"
    }
}

public class CancellationException <: Exception {
    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "CancellationException"
    }
}
