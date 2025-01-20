/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * An ObservableWriter is a wrapper on a Writer that notifies to its listeners when
 * writing to character streams.
 */
public open class ObservableWriter <: OutputStream & Resource {
    private static let MAX_STRING_BUILDER_SIZE = 4096

    var wrappedWriter: ?ObservableWriter = None
    var wrappedOutput: ?OutputStream = None

    let listeners = ArrayList<WriterListener>()
    let listenersLock = Monitor()

    private let stringBuilder = StringBuilder(MAX_STRING_BUILDER_SIZE)

    public init(wrappedWriter: ObservableWriter) {
        this.wrappedWriter = wrappedWriter
    }
    public init(wrappedOutput: OutputStream) {
        this.wrappedOutput = wrappedOutput
    }
    public init() {}

    public open override func flush(): Unit {
        notifyListeners()
        wrappedWriter?.flush()
        wrappedOutput?.flush()
    }

    public open override func isClosed(): Bool {
        if (let Some(v) <- wrappedWriter) {
            v.isClosed()
        } else if (let Some(v: Resource) <- wrappedOutput) {
            v.isClosed()
        } else {
            false
        }
    }
    public open override func close(): Unit {
        wrappedWriter?.close()
        if (let Some(v: Resource) <- wrappedOutput) {
            v.close()
        }
    }

    public open override func write(cbuf: Array<Byte>): Unit {
        wrappedWriter?.write(cbuf)
        wrappedOutput?.write(cbuf)
        let str: String = String.fromUtf8(cbuf)
        maybeNotifyListeners(str)
    }

    public open func write(str: String): Unit {
        wrappedWriter?.write(str)
        wrappedOutput?.write(unsafe { str.rawData() })
        maybeNotifyListeners(str)
    }

    public open func write(str: ToString): Unit {
        write(str.toString())
    }

    private func maybeNotifyListeners(s: String): Unit {
        stringBuilder.append(s)
        if (stringBuilder.size > MAX_STRING_BUILDER_SIZE) {
            notifyListeners()
        }
    }

    /**
     * Notify that a new string has been written.
     */
    private func notifyListeners(): Unit {
        let writerListeners: Array<WriterListener> = synchronized(listenersLock) {
            listeners.toArray()
        }
        let str: String = stringBuilder.toString()
        stringBuilder.reset()
        for (writerListener in writerListeners) {
            writerListener.write(str)
        }
    }

    /**
     * Adds a writer listener to this writer that will be notified when
     * new strings are sent.
     *
     * @param writerListener a writer listener.
     */
    public open func addWriterListener(writerListener: WriterListener): Unit {
        synchronized(listenersLock) {
            if (!listeners.contains(writerListener)) {
                listeners.add(writerListener)
            }
        }
    }

    /**
     * Removes a writer listener from this writer.
     *
     * @param writerListener a writer listener.
     */
    public open func removeWriterListener(writerListener: WriterListener): Unit {
        synchronized(listenersLock) {
            listeners.removeValue(writerListener)
        }
    }
}

/**
 * Interface that allows for implementing classes to listen for string writing
 * events. Listeners are registered with ObservableWriter objects.
 *
 * @see ObservableWriter#addWriterListener
 * @see ObservableWriter#removeWriterListener
 */
public open class WriterListener <: Equatable<WriterListener> {
    public WriterListener(let writeFunc: (String) -> Unit) {}
    /**
     * Notification that the Writer has written a new string.
     *
     * @param str the written string
     */
    public open func write(str: String): Unit {
        writeFunc(str)
    }
    public operator override func ==(that: WriterListener): Bool {
        refEq(this, that)
    }
}
