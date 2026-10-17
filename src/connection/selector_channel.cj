package xmpp4cj.connection

/**
 * {@link SelectableChannel}对象的多路复用器。
 */
public class Selector {
    private let lock = Mutex()
    private let lockCondition = condition(lock)
    /**
     * 打开选择器。
     *
     * @return 一个新的选择器
     */
    public static func open(): Selector {
        Selector()
    }

    /**
     * 通知其他阻塞的select操作立即返回
     */
    public func wakeup(): Unit {
        synchronized(lock) {
            lockCondition.notifyAll()
        }
    }

    /**
     * 选择一组SelectionKey，其相应的channel已准备好进行I/O操作。
     *
     * @param timeout 超时时间
     * @return 已就绪SelectionKey数量
     */
    public func select(timeout: Duration): Int {
        synchronized(lock) {
            if (this.keys.size == 0) {
                let timeout0 = if (timeout > Duration.Zero) {
                    timeout
                } else {
                    Duration.Max
                }
                lockCondition.wait(timeout: timeout0)
            }
            for (key in this.keys) {
                if (!key.isValid()) {
                    // 与 java.nio 一致：已取消/失效的键不再参与选择。
                    continue
                }
                if (key.checkOps()) {
                    publicKeys.add(key)
                }
            }
            publicKeys.size
        }
    }

    /**
     * 反注册选择键，将其从选择器的键集中移除。
     * 等价于 java.nio 中被取消的键在下次 select 前从键集移除的行为。
     *
     * @param key 要移除的选择键
     */
    protected func deregister(key: SelectionKey): Unit {
        synchronized(lock) {
            keys.remove(key)
            publicKeys.remove(key)
            // 唤醒可能阻塞在 select 上的线程，使其重新计算键集。
            lockCondition.notifyAll()
        }
    }

    let publicKeys = HashSet<SelectionKey>()
    /**
     * @return 已就绪的SelectionKey
     */
    public func selectedKeys(): Set<SelectionKey> {
        synchronized(lock) {
            select(Duration.nanosecond)
            publicKeys
        }
    }

    let keys = HashSet<SelectionKey>()
    protected func register(channel: SelectableChannel, ops: Int, attachment: Object): SelectionKey {
        let key = SelectionKey(this, channel, ops, attachment)
        synchronized(lock) {
            keys.add(key)
            lockCondition.notify()
        }
        key
    }
}

/**
 * public abstract class SelectableChannel
 *
 * 抽象Channel对象
 */
public abstract class SelectableChannel {
    let keys = ArrayList<SelectionKey>()
    var selector: ?Selector = None
    public func register(selector: Selector, ops: Int64, attachment: Object): SelectionKey {
        let key = selector.register(this, ops, attachment)
        keys.add(key)
        key
    }
    public func close(): Unit
    /**
     * 检查兴趣集是否就绪
     *
     * @param interestOps 新兴趣集
     * @return 若channel就绪则返回新的interestOps 否则-1
     */
    public func checkOps(interestOps: Int): Int
}

public class SocketChannel <: SelectableChannel {
    private static let ST_UNCONNECTED = 0
    private static let ST_CONNECTIONPENDING = 1
    private static let ST_CONNECTED = 2
    private static let ST_CLOSING = 3
    private static let ST_KILLPENDING = 4
    private static let ST_KILLED = 5
    private var state: Int = 0 // need stateLock to change
    private var tcpSocket: ?TcpSocket = None
    private var addr: ?IPSocketAddress = None
    public prop remoteAddress: IPSocketAddress {
        get() {
            return this.addr.getOrThrow()
        }
    }

    public static func open(): SocketChannel {
        SocketChannel()
    }
    public func connect(addr: IPSocketAddress, timeout: Duration): Bool {
        this.addr = addr
        state = ST_CONNECTIONPENDING
        let socket = TcpSocket(addr)
        tcpSocket = socket
        // 直接同步连接
        socket.connect(timeout: timeout)
        state = ST_CONNECTED

        // readAsync(socket) 

        return true
    }
    public func write(buf: Array<ByteBuffer>): Int {
        synchronized(lock) {
            if (state != ST_CONNECTED) {
                // 与 java.nio 一致：对已关闭的通道执行写操作抛出 ClosedChannelException。
                throw ClosedChannelException()
            }
            var len = 0
            for (v in buf) {
                let arr = v.bytes()
                tcpSocket?.write(arr)
                v.clear()
                len += arr.size
            }
            len
        }
    }

    private let lock = Mutex()
    private let lockCondition = condition(lock)
    /* readBuffer相关资源受lock管辖 */
    private let readBuffer = Array<Byte>(512, repeat: 0)
    private var readBufferLen = 0
    private var readFuture = unsafe { zeroValue<Future<Unit>>() } // 占位

    /*
     * 异步循环读取socket
     * (readBuffer未清空) ? (sleep && continue) : (read socket)
     */
    private func readAsync(socket: TcpSocket) {
        readFuture = spawn {
            while (true) {
                if (Thread.currentThread.hasPendingCancellation) {
                    break
                }
                try {
                    synchronized(lock) {
                        if (readBufferLen > 0) {
                            lockCondition.wait(timeout: Duration.second)
                            continue
                        }
                        socket.readTimeout = Duration.millisecond
                        readBufferLen = socket.read(readBuffer)
                    }
                } catch (_: SocketTimeoutException) { /* ignore */ } catch (e: Exception) {
                    DEBUGER.log(LogLevel.TRACE, "socket channel read error", e)
                }
            }
        }
    }
    /* public func read(buf: ByteBuffer): Int64 {
        synchronized(lock) {
            let len = readBufferLen
            if (len > 0) {
                buf.write(readBuffer[..len])
            }
            readBufferLen = 0
            lock.notify()
            return len
        }
    } */
    public func read(buf: ByteBuffer): Int64 {
        synchronized(lock) {
            if (state != ST_CONNECTED) {
                // 与 java.nio 一致：对已关闭的通道执行读操作抛出 ClosedChannelException。
                throw ClosedChannelException()
            }
            var readlen = 0
            let socket = tcpSocket.getOrThrow()
            socket.readTimeout = Duration.millisecond
            while (true) {
                try {
                    let len = socket.read(readBuffer)
                    buf.write(readBuffer[..len])
                    readlen += len
                } catch (_: SocketTimeoutException) {
                    // 只能依靠超时异常
                    break
                }
            }
            readlen
        }
    }
    public func close(): Unit {
        var needClose = false
        synchronized(lock) {
            if (state != ST_KILLED) {
                state = ST_KILLED
                needClose = true
            }
        }
        if (!needClose) {
            // 幂等：重复关闭直接返回
            return
        }
        tcpSocket?.close()
        // 与 java.nio 一致：关闭通道会取消其注册的全部选择键。
        for (key in keys.toArray()) {
            key.cancel()
        }
        keys.clear()
    }
    public func socket(): TcpSocket {
        tcpSocket.getOrThrow()
    }
    /**
     * 检查兴趣集是否就绪
     *
     * @param interestOps 新兴趣集
     * @return 若channel就绪则返回新的interestOps 否则-1
     */
    public override func checkOps(interestOps: Int): Int {
        if (state != ST_CONNECTED) {
            return -1
        }
        // 与 java.nio 一致：仅在兴趣集范围内返回就绪操作位，兴趣集为空表示不关心任何事件。
        let readyOps = SelectionKey.OP_CONNECT | SelectionKey.OP_WRITE | SelectionKey.OP_READ
        let ops = interestOps & readyOps
        if (ops == 0) {
            -1
        } else {
            ops
        }
    }
}

/**
 * 一个令牌，表示将{@link SelectableChannel}注册到{@link Selector}。
 */
public class SelectionKey <: ToString & Equatable<SelectionKey> & Hashable {
    public static let OP_READ: Int = 1 << 0
    public static let OP_WRITE: Int = 1 << 2
    public static let OP_CONNECT: Int = 1 << 3
    public static let OP_ACCEPT: Int = 1 << 4

    public SelectionKey(
        let _selector: Selector,
        let _channel: SelectableChannel,
        var _interestOps: Int,
        var _attachment: Object
    ) {}

    public override func toString(): String {
        throw Exception("TODO")
    }

    public operator override func ==(that: SelectionKey): Bool {
        refEq(this, that)
    }

    let hash = RandomUtil.nextSecureRandomInt()
    public override func hashCode(): Int {
        hash
    }

    /**
     * 该选择键是否仍然有效。等价于 java.nio 的 {@code SelectionKey.isValid()}。
     */
    private var valid = true

    /**
     * @return 若键仍然有效则返回true
     */
    public func isValid(): Bool {
        valid
    }
    /**
     * 检查兴趣集是否就绪
     *
     * @param interestOps 新兴趣集
     * @return 若channel就绪则返回新的SelectionKey 否则None
     */
    public func checkOps(): Bool {
        let ops = _channel.checkOps(_interestOps)
        ops > 0
    }
    /**
     * 设置此键的兴趣集
     *
     * @param interestOps 新兴趣集
     * @return this
     */
    public func interestOps(interestOps: Int): SelectionKey {
        this._interestOps = interestOps
        return this
    }
    /**
     * @return 获取此键的当前兴趣集
     */
    public func interestOps(): Int {
        this._interestOps
    }

    /**
     * 返回创建此密钥的频道。这种方法将即使在取消按键后，也要继续返回频道。
     *
     * @return 此键的频道
     */
    public func channel(): SelectableChannel {
        _channel
    }

    /**
     * 检索当前附件。
     *
     * @return 当前附加到此密钥的对象，如果没有附件，则<tt>None</tt>
     */
    public func attachment(): Object {
        _attachment
    }

    /**
     * 取消此键。等价于 java.nio 的 {@code SelectionKey.cancel()}：
     * 将键置为无效并从选择器的键集中反注册，但<b>不会</b>关闭通道
     * （通道的关闭由调用方显式执行）。
     */
    public func cancel(): Unit {
        if (!valid) {
            return
        }
        valid = false
        _selector.deregister(this)
    }
}

public class ClosedChannelException <: Exception {}
