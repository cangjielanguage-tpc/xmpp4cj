/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * An ObservableReader is a wrapper on a Reader that notifies to its listeners when
 * reading character streams.
 */
public open class ObservableReader <: InputStream & Resource {
    var wrappedReader: ?ObservableReader = None
    var wrappedInput: ?InputStream = None

    let listeners = ArrayList<ReaderListener>()
    let listenersLock = Monitor()

    public init(wrappedReader: ObservableReader) {
        this.wrappedReader = wrappedReader
    }
    public init(wrappedInput: InputStream) {
        this.wrappedInput = wrappedInput
    }
    public init() {
    }

    public open override func isClosed(): Bool {
        if (let Some(v) <- wrappedReader) {
            v.isClosed()
        } else if (let Some(v: Resource) <- wrappedInput) {
            v.isClosed()
        } else {
            false
        }
    }

    public open override func close(): Unit {
        wrappedReader?.close()
        if (let Some(v: Resource) <- wrappedInput) {
            v.close()
        }
    }

    public open override func read(cbuf: Array<Byte>): Int {
        let count = if (let Some(v) <- wrappedReader) {
            v.read(cbuf)
        } else {
            wrappedInput.getOrThrow().read(cbuf)
        }
        if (count > 0) {
            let str = String.fromUtf8(cbuf[..count])
            let readerListeners: Array<ReaderListener> = synchronized(listenersLock) {
                listeners.toArray()
            }
            for (i in 0..readerListeners.size) {
                readerListeners[i].read(str)
            }
        }
        return count
    }

    /**
     * Adds a reader listener to this reader that will be notified when
     * new strings are read.
     *
     * @param readerListener a reader listener.
     */
    public open func addReaderListener(readerListener: ReaderListener): Unit {
        synchronized(listenersLock) {
            if (!listeners.contains(readerListener)) {
                listeners.append(readerListener)
            }
        }
    }

    /**
     * Removes a reader listener from this reader.
     *
     * @param readerListener a reader listener.
     */
    public open func removeReaderListener(readerListener: ReaderListener): Unit {
        synchronized(listenersLock) {
            listeners.remove(readerListener)
        }
    }
}

/**
 * Interface that allows for implementing classes to listen for string reading
 * events. Listeners are registered with ObservableReader objects.
 *
 * @see ObservableReader#addReaderListener
 * @see ObservableReader#removeReaderListener
 */
public open class ReaderListener <: Equatable<ReaderListener> {
    public ReaderListener(let readFunc: (String) -> Unit) {}
    /**
     * Notification that the Reader has read a new string.
     *
     * @param str the read String
     */
    public open func read(str: String) {
        readFunc(str)
    }
    public operator override func ==(that: ReaderListener): Bool {
        refEq(this, that)
    }
}
