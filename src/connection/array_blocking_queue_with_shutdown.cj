/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * Like ArrayBlockingQueue but with additional {@link #shutdown()} and {@link #start} methods. Will
 * throw {@link IllegalStateException} if Queue has been shutdown on {@link #take()} and
 * {@link #poll(Duration)}.
 * <p>
 *
 * @param <E> the type of elements held in this collection
 */
public class ArrayBlockingQueueWithShutdown<E> <: Collection<E> {
    let items: Array<?E>

    var takeIndex: Int64 = 0

    var putIndex: Int64 = 0

    var count: Int64 = 0

    let lock: MultiConditionMonitor

    private let notEmpty: ConditionID

    private let notFull: ConditionID

    private var _isShutdown = false

    func inc(i: Int64): Int64 {
        let ii = i + 1
        if (ii == items.size) {
            0
        } else {
            ii
        }
    }

    private func insert(e: E): Unit {
        insert(e, true)
    }

    private func insert(e: E, signalNotEmpty: Bool): Unit {
        items[putIndex] = e
        putIndex = inc(putIndex)
        count++
        if (signalNotEmpty) {
            lock.notify(notEmpty)
        }
    }

    private func extract(): ?E {
        let e = items[takeIndex]
        items[takeIndex] = None
        takeIndex = inc(takeIndex)
        count--
        lock.notify(notFull)
        return e
    }

    func removeAt(i: Int64): Unit {
        var tempi = i
        if (tempi == takeIndex) {
            items[Int64(takeIndex)] = None
            takeIndex = inc(takeIndex)
        } else {
            while (true) {
                let nexti = inc(tempi)
                if (nexti != putIndex) {
                    items[Int64(tempi)] = items[Int64(nexti)]
                    tempi = nexti
                } else {
                    items[Int64(tempi)] = None
                    putIndex = tempi
                    break
                }
            }
        }
        count--
        lock.notify(notFull)
    }

    private func checkNotShutdown(): Unit {
        if (_isShutdown) {
            throw IllegalStateException("Queue was already shut down")
        }
    }

    private func hasNoElements(): Bool {
        return count == 0
    }

    private func hasElements(): Bool {
        return !hasNoElements()
    }

    private func isFull(): Bool {
        return count == items.size
    }

    private func isNotFull(): Bool {
        return !isFull()
    }

    public init(capacity: Int64) {
        this(capacity, false)
    }

    public init(capacity: Int64, fair: Bool) {
        if (capacity <= 0) {
            throw IllegalArgumentException()
        }
        items = Array<?E>(capacity, repeat: None)
        lock = MultiConditionMonitor()
        synchronized(lock) {
            notEmpty = lock.newCondition()
            notFull = lock.newCondition()
        }
    }

    /**
     * Shutdown the Queue. Will method currently waiting for a not full/empty condition will unblock
     * (and usually throw a IllegalStateException).
     */
    public func shutdown(): Unit {
        lock.lock()
        try {
            _isShutdown = true
            lock.notifyAll(notEmpty)
            lock.notifyAll(notFull)
        } finally {
            lock.unlock()
        }
    }

    /**
     * Start the queue. Newly created instances will be started automatically, thus this only needs
     * to be called after {@link #shutdown()}.
     *
     * @return <code>true</code> if the queues was shutdown before, <code>false</code> if not.
     */
    public func start(): Bool {
        let previousIsShutdown: Bool
        lock.lock()
        try {
            previousIsShutdown = _isShutdown
            _isShutdown = false
        } finally {
            lock.unlock()
        }
        return previousIsShutdown
    }

    /**
     * Returns true if the queue is currently shut down.
     *
     * @return true if the queue is shut down.
     */
    public func isShutdown(): Bool {
        lock.lock()
        try {
            return _isShutdown
        } finally {
            lock.unlock()
        }
    }

    public func poll(): ?E {
        lock.lock()
        try {
            if (hasNoElements()) {
                return None
            }
            let e = extract()
            return e
        } finally {
            lock.unlock()
        }
    }

    public func peek(): ?E {
        lock.lock()
        try {
            return if (hasNoElements()) {
                None
            } else {
                items[takeIndex]
            }
        } finally {
            lock.unlock()
        }
    }

    public func offer(e: E): Bool {
        lock.lock()
        try {
            if (isFull() || _isShutdown) {
                return false
            } else {
                insert(e)
                return true
            }
        } finally {
            lock.unlock()
        }
    }

    public func offerAndShutdown(e: E): Bool {
        let res: Bool
        lock.lock()
        try {
            res = offer(e)
            shutdown()
        } finally {
            lock.unlock()
        }
        return res
    }

    private func putInternal(e: E, signalNotEmpty: Bool): Unit {
        // assert(lock.isHeldByCurrentThread()) // do not support
        while (isFull()) {
            lock.wait(notFull)
            checkNotShutdown()
        }
        insert(e, signalNotEmpty)
    }

    /**
     * Inserts the specified element into this queue, waiting if necessary
     * for space to become available.
     * <p>
     * This may throw an {@link IllegalStateException} in two cases
     * <ol>
     *  <li>If the queue was shut down.</li>
     *  <li>If the thread was was interrupted.</li>
     * </ol>
     * So you have to check which is the case, e.g. by calling {@link #isShutdown()}.
     *
     * @param e the element to add.
     * @throws IllegalStateException if interrupted while waiting or if the queue was shut down.
     */
    public func put(e: E): Unit {
        lock.lockInterruptibly()
        try {
            putInternal(e, true)
        } finally {
            lock.unlock()
        }
    }

    /**
     * Put if the queue has not been shutdown yet.
     *
     * @param e the element to put into the queue.
     * @return <code>true</code> if the element has been put into the queue, <code>false</code> if the queue was shutdown.
     * @throws IllegalStateException if the calling thread was interrupted.
     */
    public func putIfNotShutdown(e: E): Bool {
        lock.lockInterruptibly()
        try {
            if (_isShutdown) {
                return false
            }
            putInternal(e, true)
            return true
        } finally {
            lock.unlock()
        }
    }

    public func putAll(elements: Collection<E>): Unit {
        lock.lockInterruptibly()
        try {
            for (element in elements) {
                putInternal(element, false)
            }
        } finally {
            lock.notifyAll(notEmpty)
            lock.unlock()
        }
    }

    public func tryPut(e: E): ArrayBlockingQueueWithShutdownTryPutResult {
        let locked = lock.tryLock()
        if (!locked) {
            return ArrayBlockingQueueWithShutdownTryPutResult.couldNotLock
        }
        try {
            if (_isShutdown) {
                return ArrayBlockingQueueWithShutdownTryPutResult.queueWasShutDown
            }
            if (isFull()) {
                return ArrayBlockingQueueWithShutdownTryPutResult.queueWasFull
            }
            insert(e)
            return ArrayBlockingQueueWithShutdownTryPutResult.putSuccessful
        } finally {
            lock.unlock()
        }
    }

    public func offer(e: E, timeout: Duration): Bool {
        var nanos = timeout
        lock.lockInterruptibly()
        try {
            while (true) {
                if (isNotFull()) {
                    insert(e)
                    return true
                }
                if (nanos <= Duration.Zero) {
                    return false
                }
                try {
                    lock.wait(notFull, timeout: nanos)
                    nanos = Duration.Zero
                    checkNotShutdown()
                } catch (ie: Exception) {
                    lock.notify(notFull)
                    throw ie
                }
            }
        } finally {
            lock.unlock()
        }
        throw IllegalStateException("should not reach here")
    }

    public func take(): ?E {
        lock.lockInterruptibly()
        try {
            checkNotShutdown()
            try {
                while (hasNoElements()) {
                    lock.wait(notEmpty)
                    checkNotShutdown()
                }
            } catch (ie: Exception) {
                lock.notify(notEmpty)
                throw ie
            }
            let e = extract()
            return e
        } finally {
            lock.unlock()
        }
    }

    public func tryTake(): ArrayBlockingQueueWithShutdownTryTakeResult<E> {
        let locked = lock.tryLock()
        if (!locked) {
            return ArrayBlockingQueueWithShutdownTryTakeResult<E>(
                ArrayBlockingQueueWithShutdownTryTakeResultCode.couldNotLock)
        }
        try {
            if (_isShutdown) {
                return ArrayBlockingQueueWithShutdownTryTakeResult<E>(
                    ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasShutDown)
            }
            if (hasNoElements()) {
                return ArrayBlockingQueueWithShutdownTryTakeResult<E>(
                    ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasEmpty)
            }
            let element = extract()
            return ArrayBlockingQueueWithShutdownTryTakeResult<E>(element)
        } finally {
            lock.unlock()
        }
    }

    public func poll(timeout: Duration): ?E {
        var nanos = timeout
        lock.lockInterruptibly()
        try {
            checkNotShutdown()
            while (true) {
                if (hasElements()) {
                    let e = extract()
                    return e
                }
                if (nanos <= Duration.Zero) {
                    return None
                }
                try {
                    lock.wait(notEmpty, timeout: nanos)
                    nanos = Duration.Zero
                    checkNotShutdown()
                } catch (ie: Exception) {
                    lock.notify(notEmpty)
                    throw ie
                }
            }
        } finally {
            lock.unlock()
        }
        throw IllegalStateException("should not reach here")
    }

    public func remainingCapacity(): Int64 {
        lock.lock()
        try {
            return items.size - count
        } finally {
            lock.unlock()
        }
    }

    public func drainTo(c: ArrayList<E>): Int64 {
        lock.lock()
        try {
            var i = takeIndex
            var n = 0
            while (n < count) {
                c.append(items[i].getOrThrow())
                items[i] = None
                i = inc(i)
                n++
            }
            if (n > 0) {
                count = 0
                putIndex = 0
                takeIndex = 0
                lock.notifyAll(notFull)
            }
            return n
        } finally {
            lock.unlock()
        }
    }

    public func drainTo(c: ArrayList<E>, maxElements: Int64): Int64 {
        if (maxElements <= 0) {
            return 0
        }
        lock.lock()
        try {
            var i = takeIndex
            var n = 0
            let max = if (maxElements < count) {
                maxElements
            } else {
                count
            }
            while (n < max) {
                c.append(items[i].getOrThrow())
                items[i] = None
                i = inc(i)
                n++
            }
            if (n > 0) {
                count -= n
                takeIndex = i
                lock.notifyAll(notFull)
            }
            return n
        } finally {
            lock.unlock()
        }
    }

    public override prop size: Int64 {
        get() {
            lock.lock()
            try {
                return count
            } finally {
                lock.unlock()
            }
        }
    }

    public override func isEmpty(): Bool {
        size == 0
    }

    public override func iterator(): Iterator<E> {
        lock.lock()
        try {
            return ArrayBlockingQueueWithShutdownIterator<E>(this)
        } finally {
            lock.unlock()
        }
    }

    public func remove(): E {
        poll().getOrThrow {=> NoSuchElementException()}
    }

    public func clear(): Unit {
        synchronized(lock) {
            while (count > 0) {
                extract()
            }
        }
    }
}

public class ArrayBlockingQueueWithShutdownTryTakeResult<E> {
    private let element: ?E

    private let resultCode: ArrayBlockingQueueWithShutdownTryTakeResultCode

    init(resultCode: ArrayBlockingQueueWithShutdownTryTakeResultCode) {
        this.resultCode = resultCode
        this.element = None
    }

    init(element: ?E) {
        assert(element.isSome())
        this.resultCode = ArrayBlockingQueueWithShutdownTryTakeResultCode.takeSuccessful
        this.element = element
    }

    public func getResultCode(): ArrayBlockingQueueWithShutdownTryTakeResultCode {
        return resultCode
    }

    public func getElement(): ?E {
        return element
    }
}

public enum ArrayBlockingQueueWithShutdownTryTakeResultCode <: ToString & Equatable<ArrayBlockingQueueWithShutdownTryTakeResultCode> {
    /**
     * The method was unable to acquire the queue lock.
     */
    | couldNotLock

    /**
     * The queue was shut down.
     */
    | queueWasShutDown

    /**
     * The queue was empty.
     */
    | queueWasEmpty

    /**
     * An element was successfully removed from the queue.
     */
    | takeSuccessful

    public override func toString(): String {
        return match (this) {
            case couldNotLock => "couldNotLock"
            case queueWasShutDown => "queueWasShutDown"
            case queueWasEmpty => "queueWasEmpty"
            case takeSuccessful => "takeSuccessful"
        }
    }

    public operator func ==(that: ArrayBlockingQueueWithShutdownTryTakeResultCode): Bool {
        this.toString() == that.toString()
    }
}

public enum ArrayBlockingQueueWithShutdownTryPutResult <: ToString & Equatable<ArrayBlockingQueueWithShutdownTryPutResult> {
    /**
     * The method was unable to acquire the queue lock.
     */
    | couldNotLock

    /**
     * The queue was shut down.
     */
    | queueWasShutDown

    /**
     * The method was unable to put another element into the queue because the queue was full.
     */
    | queueWasFull

    /**
     * The element was successfully placed into the queue.
     */
    | putSuccessful

    public override func toString(): String {
        return match (this) {
            case couldNotLock => "couldNotLock"
            case queueWasShutDown => "queueWasShutDown"
            case queueWasFull => "queueWasFull"
            case putSuccessful => "putSuccessful"
        }
    }

    public operator func ==(that: ArrayBlockingQueueWithShutdownTryPutResult): Bool {
        this.toString() == that.toString()
    }
}

class ArrayBlockingQueueWithShutdownIterator<E> <: Iterator<E> {
    private var nextIndex: Int64 = 0
    private var nextItem: ?E
    private var lastRet: Int64 = 0

    var abqs: ArrayBlockingQueueWithShutdown<E>

    init(abqs: ArrayBlockingQueueWithShutdown<E>) {
        this.abqs = abqs
        lastRet = -1
        if (abqs.count == 0) {
            nextIndex = -1
            nextItem = None
        } else {
            nextIndex = abqs.takeIndex
            nextItem = abqs.items[abqs.takeIndex]
        }
    }

    public func hasNext(): Bool {
        return nextIndex >= 0
    }

    private func checkNext(): Unit {
        if (nextIndex == abqs.putIndex) {
            nextIndex = -1
            nextItem = None
        } else {
            nextItem = abqs.items[nextIndex]
            if (nextItem.isNone()) {
                nextIndex = -1
            }
        }
    }

    public override func next(): ?E {
        abqs.lock.lock()
        try {
            if (nextIndex < 0) {
                throw NoSuchElementException()
            }
            lastRet = nextIndex
            let e = nextItem
            nextIndex = abqs.inc(nextIndex)
            checkNext()
            return e
        } finally {
            abqs.lock.unlock()
        }
    }

    public func remove(): Unit {
        abqs.lock.lock()
        try {
            let i = lastRet
            if (i < 0) {
                throw IllegalStateException()
            }
            lastRet = -1
            let ti = abqs.takeIndex
            abqs.removeAt(i)
            nextIndex = if (i == ti) {
                abqs.takeIndex
            } else {
                i
            }
            checkNext()
        } finally {
            abqs.lock.unlock()
        }
    }
}

extend MultiConditionMonitor {
    /* 
     * 优先响应线程中断状态
     * 暂时不考虑自旋
     * 阻塞lock
     */
    func lockInterruptibly() {
        if (Thread.currentThread.hasPendingCancellation) {
            throw IllegalStateException()
        }
        lock()
    }
}

public class NoSuchElementException <: Exception {}
