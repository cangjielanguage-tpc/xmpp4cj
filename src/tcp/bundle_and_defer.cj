/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class BundleAndDefer {
    static let isStoppedLock: Monitor = Monitor()

    private let isStopped: AtomicBool

    init(isStopped: AtomicBool) {
        this.isStopped = isStopped
    }

    /**
     * Stop the bundle and defer mechanism that was started when this instance of {@link BundleAndDefer} was emitted by
     * Xmpp.
     * <p>
     * It is possible that the defer period already expired when this is invoked. In this case this method is basically
     * a no-op.
     * </p>
     */
    public func stopCurrentBundleAndDefer(): Unit {
        synchronized(isStoppedLock) {
            if (isStopped.load()) {
                return
            }
            isStopped.store(true)
            isStoppedLock.notify()
        }
    }
}
