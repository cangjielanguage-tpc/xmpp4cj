/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * IQ request handler are responsible for handling incoming IQ requests. They can be registered with
 * {@link xmpp4cj.XMPPConnection#registerIQRequestHandler(IQRequestHandler)}.
 *
 * @see AbstractIqRequestHandler
 */
public interface IQRequestHandler {
    func handleIQRequest(iqRequest: IQ): IQ

    func getMode(): IQRequestHandlerMode

    func getType(): IQType

    func getElement(): String

    func getNamespace(): String

    func getQName(): QName {
        return QName(getNamespace(), getElement())
    }
}

public enum IQRequestHandlerMode <: ToString & Equatable<IQRequestHandlerMode> {
    /**
     * Process requests synchronously, i.e. in the order they arrive. Uses a single thread, which means that the other
     * requests have to wait until all previous synchronous requests have been handled. Use {@link #async} if
     * possible for performance reasons.
     */
    | sync

    /**
     * Process IQ requests asynchronously, i.e. concurrent. This does not guarantee that requests are processed in the
     * same order they arrive.
     */
    | async

    public override func toString(): String {
        return match (this) {
            case sync => "sync"
            case async => "async"
        }
    }

    public operator func ==(that: IQRequestHandlerMode): Bool {
        return match ((this, that)) {
            case (sync, sync) => true
            case (async, async) => true
            case _ => false
        }
    }
}
