/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

/**
 * 用于非阻塞I/O的Xmpp反应器。
 */
public class XmppReactor {
    /**
     * 日志记录器。
     */
    static let LOGGER = getGlobalLogger(("name", "XmppReactor"))

    /**
     * 默认的反应线程数量。
     */
    private static let DEFAULT_REACTOR_THREAD_COUNT = 2

    static let PENDING_SET_INTEREST_OPS_MAX_BATCH_SIZE = 1024

    private static var INSTANCE: ?XmppReactor = None

    private static var INSTANCE_LOCK = Monitor()

    static func getInstance(): XmppReactor {
        synchronized(INSTANCE_LOCK) {
            return INSTANCE ?? {
                =>
                let reactor = XmppReactor("DefaultReactor")
                INSTANCE = reactor
                reactor
            }()
        }
    }

    /**
     * 选择器，用于管理通道的选择
     */
    let selector: Selector

    let selectorLock = Monitor()

    /**
     * 反应器的名称
     */
    private let reactorName: String

    /** 
     * 存储反应线程的列表
     */
    let reactorThreads = ConcurrentLinkedQueue<ReactorThread>()

    let reactorThreadsLock = Monitor()

    /** 
     * 延迟队列，用于调度的动作
     */
    let scheduledActions = DelayQueue<ScheduledAction>()

    /** 
     * 注册锁，用于保护注册操作
     */
    let registrationLock = Monitor()

    /**  
     * 保护动作处理的信号量。注意，它初始化为 -1，这意味着 * 一直会有一个线程使用 select()进行 I/O 操作。
     */
    let actionsSemaphore = {
        =>
        let count = 1 << 10
        let sem = Semaphore(count)
        sem.acquire(amount: count)
        sem
    }()

    /**
     * 存储待处理的选择键的队列。
     */
    let pendingSelectionKeys: NonBlockingQueue<SelectionKey> = NonBlockingQueue()

    /**
     * 存储待处理的设置兴趣操作的队列。
     */
    let pendingSetInterestOps: NonBlockingQueue<XmppReactorSetInterestOps> = NonBlockingQueue()

    /**  
     * 构造函数，初始化反应器名称并打开选择器。
     *
     * @param reactorName反应器的名称
     */
    init(reactorName: String) {
        this.reactorName = reactorName
        selector = Selector.open()
        setReactorThreadCount(DEFAULT_REACTOR_THREAD_COUNT)
    }

    /**  
     * 将通道注册到选择器。
     *
     * @param channel 可选择的通道
     * @param ops选择的操作
     * @param callback 通道选择回调
     * @return 注册的选择键
     * @throws ClosedChannelException 如果通道已关闭
     */
    public func registerWithSelector(channel: SelectableChannel, ops: Int, callback: XmppReactorChannelSelectedCallback): SelectionKey {
        let selectionKeyAttachment = XmppReactorSelectionKeyAttachment(callback)
        registrationLock.lock()
        try {
            selector.wakeup()
            return channel.register(selector, ops, selectionKeyAttachment)
        } finally {
            registrationLock.unlock()
        }
    }

    /**  
     * 设置选择键的兴趣操作。
     *
     * @param selectionKey选择键
     * @param interestOps 兴趣操作
     */
    public func setInterestOps(selectionKey: SelectionKey, interestOps: Int): Unit {
        let setInterestOps = XmppReactorSetInterestOps(selectionKey, interestOps)
        pendingSetInterestOps.enqueue(setInterestOps)
        selector.wakeup()
    }

    /**  
     * 调度一个可运行的任务。
     *
     * @param runnable 要调度的任务
     * @param delay 延迟时间
     * @param unit 时间单位
     * @param scheduledActionKind 调度动作的类型
     * @return 调度的动作
     */
    public func schedule(runnable: Runnable, delay: Duration, scheduledActionKind: ScheduledActionKind): ScheduledAction {
        let releaseTimeDate = DateTime.now() + delay
        let scheduledAction = ScheduledAction(runnable, releaseTimeDate, this, scheduledActionKind)
        scheduledActions.append(scheduledAction)
        selector.wakeup()
        return scheduledAction
    }

    /**  
     * 取消调度的动作。
     *
     * @param scheduledAction 要取消的调度动作
     * @return 如果调度动作仍在等待并被移除，则返回 <code>true</code>；否则返回 <code>false</code>。
     */
    func cancel(scheduledAction: ScheduledAction): Bool {
        return scheduledActions.remove(scheduledAction)
    }

    /**  
     * 处理已选择的键。
     *
     * @param selectedKeys 已选择的键集合
     */
    static func handleSelectedKeys(selectedKeys: Collection<SelectionKey>): Unit {
        for (selectionKey in selectedKeys) {
            let channel = selectionKey.channel()
            let selectionKeyAttachment = selectionKey.attachment() as XmppReactorSelectionKeyAttachment
            let channelSelectedCallback = selectionKeyAttachment?.channelSelectedCallback
            channelSelectedCallback?(channel, selectionKey)
        }
    }

    /**  
     * 设置反应线程的数量。
     *
     * @param reactorThreadCount反应线程的数量
     */
    public func setReactorThreadCount(reactorThreadCount: Int64): Unit {
        if (reactorThreadCount < 2) {
            throw IllegalArgumentException(
                "Must have at least two reactor threads, but you requested ${reactorThreadCount}")
        }
        synchronized(reactorThreadsLock) {
            var deltaThreads = reactorThreadCount - reactorThreads.size
            if (deltaThreads > 0) {
                // Start new reactor thread. Note that we start the threads before we increase the permits of the
                // actionsSemaphore.
                var i = 0
                while (i < deltaThreads) {
                    let reactor = ReactorThread(this)
                    // reactor.setDaemon(true) // cangjie Thread 无此特性
                    reactor.setName("Xmpp ${reactorName} Thread #${i}")
                    reactorThreads.append(reactor)
                    reactor.start()
                    i++
                }
                actionsSemaphore.release(amount: deltaThreads)
            } else {
                // Stop existing reactor threads. First we change the sign of deltaThreads, then we decrease the permits
                // of the actionsSemaphore *before* we signal the selected reactor threads that they should shut down.
                deltaThreads -= deltaThreads
                var i = deltaThreads - 1
                while (i > 0) {
                    // Note that this could potentially block forever, starving on the unfair semaphore.
                    actionsSemaphore.acquire()
                    i--
                }
                i = deltaThreads - 1
                while (i > 0) {
                    let reactor = reactorThreads.remove(i)
                    reactor?.requestShutdown()
                    i--
                }
                selector.wakeup()
            }
        }
    }
}

class XmppReactorSetInterestOps {
    XmppReactorSetInterestOps(let selectionKey: SelectionKey, let interestOps: Int) {}
}

class ReactorThread {
    let this_0: XmppReactor
    init(this_0: XmppReactor) {
        this.this_0 = this_0
    }

    var threadName: String = ""
    public func setName(threadName: String) {
        this.threadName = threadName
    }
    public func start() {
        spawn {
            Thread.currentThread.name = threadName
            run()
        }
    }

    private var shutdownRequestTimestamp = Duration.Zero
    public func run(): Unit {
        try {
            reactorLoop()
        } finally {
            if (shutdownRequestTimestamp > Duration.Zero) {
                let shutDownDelay = DateTime.now().toUnixTimeStamp() - shutdownRequestTimestamp
                XmppReactor.LOGGER.info(
                    "XmppReactorReactor:${threadName} shut down after ${shutDownDelay.toMilliseconds()}ms")
            } else {
                let contained = [false]
                this_0.reactorThreads.remove(this)
                assert(contained[0])
            }
        }
    }

    private func reactorLoop(): Unit {
        while (shutdownRequestTimestamp < Duration.Zero) {
            handleScheduledActionsOrPerformSelect()
            handlePendingSelectionKeys()
        }
    }

    private func handleScheduledActionsOrPerformSelect(): Unit {
        var dueScheduledAction: ?ScheduledAction = None
        let permitToHandleScheduledActions = this_0.actionsSemaphore.tryAcquire()
        if (permitToHandleScheduledActions) {
            try {
                dueScheduledAction = this_0.scheduledActions.poll()
            } finally {
                this_0.actionsSemaphore.release()
            }
        }
        if (let Some(v) <- dueScheduledAction) {
            v.run()
            return
        }
        var newSelectedKeysCount = 0
        let selectedKeys: ArrayList<SelectionKey>
        synchronized(this_0.selectorLock) {
            let nextScheduledAction: ?ScheduledAction = this_0.scheduledActions.peek()
            let selectWait: Duration = if (let Some(nextScheduledAction) <- nextScheduledAction) {
                let dur = nextScheduledAction.getTimeToDueMillis()
                if (dur <= Duration.Zero) {
                    // A scheduled action was just released and became ready to execute.
                    return
                } else {
                    dur
                }
            } else {
                // There is no next scheduled action, wait indefinitely in select()
                // or until another thread invokes selector.wakeup().
                Duration.Zero
            }

            // Before we call select, we handle the pending the interest Ops.
            // This will not block since no other thread is currently in select() at this time.
            // Note: This was put deliberately before the registration lock.
            // It may cause more synchronization but allows for more parallelism.
            // Hopefully that assumption is right.
            var myHandledPendingSetInterestOps = 0
            while (let Some(setInterestOps) <- this_0.pendingSetInterestOps.dequeue()) {
                setInterestOpsCancelledKeySafe(setInterestOps.selectionKey, setInterestOps.interestOps)
                let flag = myHandledPendingSetInterestOps >= XmppReactor.PENDING_SET_INTEREST_OPS_MAX_BATCH_SIZE
                myHandledPendingSetInterestOps++
                if (flag) {
                    // This thread has handled enough "set pending interest ops" requests. Wakeup another one to
                    // handle the remaining (if any).
                    this_0.selector.wakeup()
                    break
                }
            }

            // Ensure that a wakeup() in registerWithSelector() gives the corresponding
            // register() in the same method the chance to actually register the channel.
            // In other words: This construct ensures that there is never another select()
            // between a corresponding wakeup() and register() calls.
            this_0.registrationLock.lock()
            this_0.registrationLock.unlock()

            try {
                newSelectedKeysCount = this_0.selector.select(selectWait)
            } catch (e: IOException) {
                XmppReactor.LOGGER.log(LogLevel.ERROR, "IOException while using select()", e)
                return
            }
            if (newSelectedKeysCount == 0) {
                return
            }

            // Copy the selected-key set over to selectedKeys, remove the keys from the
            // selected key set and loose interest of the key OPs for the time being.
            // Note that we perform this operation in two steps in order to maximize the
            // timespan setRacing() is set.
            let selectedKeySet = this_0.selector.selectedKeys()
            for (selectionKey in selectedKeySet) {
                let selectionKeyAttachment = selectionKey.attachment() as XmppReactorSelectionKeyAttachment
                selectionKeyAttachment?.setRacing()
            }
            for (selectionKey in selectedKeySet) {
                setInterestOpsCancelledKeySafe(selectionKey, 0)
            }

            selectedKeys = ArrayList<SelectionKey>(selectedKeySet.size)
            selectedKeys.appendAll(selectedKeySet)
            selectedKeySet.clear()
        }

        let selectedKeysCount = selectedKeys.size
        let currentReactorThreadCount = this_0.reactorThreads.size
        let myKeyCount: Int = if (selectedKeysCount > currentReactorThreadCount) {
            selectedKeysCount / currentReactorThreadCount
        } else {
            selectedKeysCount
        }

        let reactorSelectStatsLogLevel = LogLevel.TRACE
        if (XmppReactor.LOGGER.isLoggable(reactorSelectStatsLogLevel)) {
            XmppReactor.LOGGER.log(
                reactorSelectStatsLogLevel,
                "New selected key count: ${newSelectedKeysCount}. Total selected key count ${selectedKeysCount}. My key count: ${myKeyCount}. Current reactor thread count: ${currentReactorThreadCount}"
            )
        }

        let mySelectedKeys = ArrayList<SelectionKey>(myKeyCount)
        let it: Iterator<SelectionKey> = selectedKeys.iterator()
        var i = 0
        while (i < myKeyCount) {
            let selectionKey = it.next().getOrThrow()
            mySelectedKeys.append(selectionKey)
            i++
        }
        while (let Some(selectionKey) <- it.next()) {
            // Drain to pendingSelectionKeys.
            this_0.pendingSelectionKeys.enqueue(selectionKey)
        }

        if (selectedKeysCount - myKeyCount > 0) {
            // There where pending selection keys: Wakeup another reactor thread to handle them.
            this_0.selector.wakeup()
        }
        XmppReactor.handleSelectedKeys(mySelectedKeys)
    }

    private func handlePendingSelectionKeys(): Unit {
        let pendingSelectionKeysSize = this_0.pendingSelectionKeys.size
        if (pendingSelectionKeysSize == 0) {
            return
        }
        let currentReactorThreadCount = this_0.reactorThreads.size
        var myKeyCount = pendingSelectionKeysSize / currentReactorThreadCount
        if (myKeyCount == 0) {
            myKeyCount = 1
        }
        let selectedKeys: ArrayList<SelectionKey> = ArrayList<SelectionKey>(myKeyCount)
        var i = 0
        while (i < myKeyCount) {
            let selectionKey = this_0.pendingSelectionKeys.dequeue() ?? break
            selectedKeys.append(selectionKey)
            i++
        }
        if (this_0.pendingSelectionKeys.size != 0) {
            this_0.selector.wakeup()
        }
        XmppReactor.handleSelectedKeys(selectedKeys)
    }

    private func setInterestOpsCancelledKeySafe(selectionKey: SelectionKey, interestOps: Int): Unit {
        try {
            selectionKey.interestOps(interestOps)
        } catch (e: Exception) {
            let keyCancelledLogLevel = LogLevel.TRACE
            if (XmppReactor.LOGGER.isLoggable(keyCancelledLogLevel)) {
                XmppReactor.LOGGER.log(keyCancelledLogLevel, "Key '${selectionKey}' has been cancelled", e)
            }
        }
    }

    public func requestShutdown(): Unit {
        shutdownRequestTimestamp = DateTime.now().toUnixTimeStamp()
    }
}

public type XmppReactorChannelSelectedCallback = (SelectableChannel, SelectionKey) -> Unit

/**  
 * 选择键附加信息，用于处理通道选择的回调和线程竞争状态。
 */
public class XmppReactorSelectionKeyAttachment {
    /**  
     * 通道选择回调接口。
     */
    let channelSelectedCallback: XmppReactorChannelSelectedCallback

    /**  
     * 原子布尔值，用于跟踪反应线程的竞争状态。
     */
    private let reactorThreadRacing = AtomicBool(false)

    /**  
     * 构造函数，初始化通道选择回调。
     *
     * @param channelSelectedCallback 通道选择回调实例
     */
    init(channelSelectedCallback: XmppReactorChannelSelectedCallback) {
        this.channelSelectedCallback = channelSelectedCallback
    }

    /**  
     * 设置反应线程竞争状态为真。
     * 使用 lazySet 是因为只要值不立即可见就足够了。
     */
    public func setRacing(): Unit {
        // We use lazySet here since it is sufficient if the value does not become visible immediately.
        reactorThreadRacing.store(true)
    }

    /**  
     * 重置反应线程竞争状态为假。
     */
    public func resetReactorThreadRacing(): Unit {
        reactorThreadRacing.store(false)
    }

    /**  
     * 检查反应线程是否处于竞争状态。
     *
     * @return 如果反应线程处于竞争状态，返回 <code>true</code>；否则返回 <code>false</code>。
     */
    public func isReactorThreadRacing(): Bool {
        return reactorThreadRacing.load()
    }
}

/**  
 * 一个令牌，表示将{@link SelectableChannel}注册到{@link Selector}。
 */
public class SelectionKey <: ToString & Equatable<SelectionKey> {
    public override func toString(): String {
        throw Exception("TODO")
    }

    public operator override func ==(that: SelectionKey): Bool {
        refEq(this, that)
    }

    /**  
     * 将此键的兴趣集设置为给定值。
     * <p>此方法可以随时调用。无论它是否阻塞，
     * 以及多长时间取决于实施</p
     *
     * @param interestOps 新兴趣集
     * @return 选择键
     */
    func interestOps(interestOps: Int): Int {
        throw Exception("TODO")
    }

    /**  
     * 返回创建此密钥的频道。这种方法将即使在取消按键后，也要继续返回频道。
     *
     * @return 此键的频道
     */
    public func channel(): SelectableChannel {
        throw Exception("TODO")
    }

    /**  
     * 检索当前附件。
     *
     * @return 当前附加到此密钥的对象，如果没有附件，则<tt>None</tt>
     */
    public func attachment(): Any {
        throw Exception("TODO")
    }
}

/**  
 * 可以通过{@link Selector}进行多路复用的通道。
 */
public class SelectableChannel {
    /**  
     * 使用给定的选择器注册此通道，返回一个选择钥匙。
     *
     * @param selector 用于注册此频道的选择器
     * @param ops 为生成的密钥设置的兴趣
     * @param selectionKeyAttachment 生成密钥的附件；可以是<tt>None</tt>
     * @return 代表此频道注册的密钥给定的选择器
     */
    func register(selector: Selector, ops: Int, selectionKeyAttachment: Any): SelectionKey {
        throw Exception("TODO")
    }
}

/**  
 * {@link SelectableChannel}对象的多路复用器。
 */
public class Selector {
    /**  
     * 打开选择器。
     *
     * @return 一个新的选择器
     */
    static func open(): Selector {
        Selector()
    }

    /**  
     * 使尚未返回的第一个选择操作立即返回。
     */
    func wakeup() {
        throw Exception("TODO")
    }

    /**  
     * 选择一组键，其相应的通道已准备好进行I/O操作。
     *
     * @param dur 超时时间
     */
    func select(dur: Duration) {
        throw Exception("TODO")
    }

    /**  
     * 返回此选择器的选定密钥集。
     *
     * @return 此选择器的选定密钥集
     */
    func selectedKeys(): Set<SelectionKey> {
        throw Exception("TODO")
    }
}
