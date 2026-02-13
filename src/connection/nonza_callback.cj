/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

public open class NonzaCallback {
    protected let connection: AbstractXMPPConnection

    protected let filterAndListeners: Map<QName, NonzaCallbackClassAndConsumer>

    /*this is private*/
    init(builder: NonzaCallbackBuilder) {
        this.connection = builder.connection
        this.filterAndListeners = builder.filterAndListeners

        // install() // open class 不允许调用 由外部构造者调用
    }

    public func onNonzaReceived(nonza: Nonza): Unit {
        let key = nonza.getQName()
        let classAndConsumer = filterAndListeners.get(key)
        classAndConsumer?.accept(nonza)
    }

    public func cancel(): Unit {
        for ((filterKey, _) in filterAndListeners) {
            synchronized(connection.nonzaCallbacksMap.lock) {
                connection.nonzaCallbacksMap.removeOne(filterKey, this)
            }
        }
    }

    protected func install(): Unit {
        if (filterAndListeners.isEmpty()) {
            return
        }
        for ((key, _) in filterAndListeners) {
            synchronized(connection.nonzaCallbacksMap.lock) {
                connection.nonzaCallbacksMap.put(key, this)
            }
        }
    }

    static func sendAndWaitForResponse<SN, FN>(
        builder: NonzaCallbackBuilder,
        nonza: Nonza,
        successNonzaClass: ClassId,
        failedNonzaClass: ClassId
    ): ?SN where SN <: Nonza, FN <: Nonza {
        let nonzaCallback = NonzaCallbackNonzaResponseCallback<SN, FN>(successNonzaClass, failedNonzaClass, builder)
        var successNonza: ?SN = None
        try {
            nonzaCallback.connection.sendNonza(nonza)
            successNonza = nonzaCallback.waitForResponse()
        } finally {
            nonzaCallback.cancel()
        }
        return successNonza
    }
}

class NonzaCallbackNonzaResponseCallback<SN, FN> <: NonzaCallback where SN <: Nonza, FN <: Nonza {
    var successNonza: ?SN = None
    var failedNonza: ?FN = None
    let lock = Monitor()

    init(successNonzaClass: ClassId, failedNonzaClass: ClassId, builder: NonzaCallbackBuilder) {
        super(builder)
        install()

        let successNonzaKey = XmppElementUtil.getQNameFor(successNonzaClass)
        let failedNonzaKey = XmppElementUtil.getQNameFor(failedNonzaClass)

        let successListener: NonzaCallbackNonzaListener = {
            _successNonza =>
            successNonza = _successNonza as SN
            notifyResponse()
        }
        let successClassAndConsumer = NonzaCallbackClassAndConsumer(successNonzaClass, successListener)

        let failedListener: NonzaCallbackNonzaListener = {
            _failedNonza =>
            failedNonza = _failedNonza as FN
            notifyResponse()
        }
        let failedClassAndConsumer = NonzaCallbackClassAndConsumer(failedNonzaClass, failedListener)

        filterAndListeners.add(successNonzaKey, successClassAndConsumer)
        filterAndListeners.add(failedNonzaKey, failedClassAndConsumer)
        install()
    }

    public func notifyResponse(): Unit {
        synchronized(lock) {
            lock.notifyAll()
        }
    }

    private func hasReceivedSuccessOrFailedNonza(): Bool {
        return successNonza.isSome() || failedNonza.isSome()
    }

    public func waitForResponse(): SN {
        let deadline = DateTime.now() + connection.getReplyTimeout()
        synchronized(lock) {
            while (!hasReceivedSuccessOrFailedNonza()) {
                let now = DateTime.now()
                if (now >= deadline) {
                    break
                }
                lock.wait(timeout: deadline - now)
            }
        }
        if (!hasReceivedSuccessOrFailedNonza()) {
            throw NoResponseException.newWith(connection, "Nonza Listener")
        }
        if (let Some(failedNonza) <- failedNonza) {
            throw FailedNonzaException(failedNonza)
        }

        return successNonza.getOrThrow {=> AssertionError()}
    }
}

public class NonzaCallbackBuilder {
    let connection: AbstractXMPPConnection

    var filterAndListeners: Map<QName, NonzaCallbackClassAndConsumer> = HashMap()

    init(connection: AbstractXMPPConnection) {
        this.connection = connection
    }

    public func listenFor(nonza: ClassId, nonzaListener: NonzaCallbackNonzaListener): NonzaCallbackBuilder {
        let key = XmppElementUtil.getQNameFor(nonza)
        let classAndConsumer = NonzaCallbackClassAndConsumer(nonza, nonzaListener)
        filterAndListeners.add(key, classAndConsumer)
        return this
    }

    public func install(): NonzaCallback {
        let v = NonzaCallback(this)
        v.install()
        v
    }
}

/**
 * public type NonzaCallbackNonzaListener = (Nonza) -> Unit
 */
public type NonzaCallbackNonzaListener = (Nonza) -> Unit

public class NonzaCallbackClassAndConsumer {
    private let clazz: ClassId
    private let consumer: NonzaCallbackNonzaListener

    init(clazz: ClassId, consumer: NonzaCallbackNonzaListener) {
        this.clazz = clazz
        this.consumer = consumer
    }

    public func accept(object: Nonza): Unit {
        let nonza = object
        consumer(nonza)
    }
}
