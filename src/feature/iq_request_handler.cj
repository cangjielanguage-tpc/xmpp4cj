/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.feature

/**
 * IQ 请求处理器负责处理传入的 IQ 请求。可以通过
 * {@link XMPPConnection#registerIQRequestHandler(IQRequestHandler)} 注册。
 *
 * @see AbstractIqRequestHandler
 */
public interface IQRequestHandler {
    /**
     * 处理传入的 IQ 请求。
     *
     * @param iqRequest 要处理的 IQ 请求
     * @return 处理后的 IQ 响应
     */
    func handleIQRequest(iqRequest: IQ): ?IQ

    /**
     * 获取处理器的模式。
     *
     * @return 处理模式（同步或异步）
     */
    func getMode(): IQRequestHandlerMode

    /**
     * 获取处理器所处理的 IQ 请求的类型。
     *
     * @return IQ 请求类型
     */
    func getType(): IQType

    /**
     * 获取处理器所处理的元素名称。
     *
     * @return 元素名称
     */
    func getElement(): String

    /**
     * 获取处理器所处理的命名空间。
     *
     * @return 命名空间
     */
    func getNamespace(): String

    /**
     * 获取处理器的完全限定名（QName）。
     *
     * @return 完全限定名（QName）
     */
    func getQName(): QName {
        return QName(getNamespace(), getElement())
    }
}

public enum IQRequestHandlerMode <: ToString & Equatable<IQRequestHandlerMode> {
    /**
     * 以同步方式处理请求，即按到达顺序处理。使用单线程，这意味着其他请求必须等待
     * 直到所有先前的同步请求被处理完毕。出于性能考虑，如果可能的话，请使用 {@link #async}。
     */
    | sync

    /**
     * 以异步方式处理 IQ 请求，即并发处理。这并不保证请求按照到达顺序被处理。
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
