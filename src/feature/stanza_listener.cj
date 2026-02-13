/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.feature

/**
 * 提供一个机制，用于监听通过指定过滤器的消息包（stanza）。
 * 这允许事件风格的编程——每当发现一个新的消息包时，
 * {@link #processStanza(Stanza)} 方法将被调用。这与 {@link StanzaCollector}
 * 提供的功能相反，后者允许你在等待结果时阻塞。
 * <p>
 * 此外，你还可以拦截即将发送的消息包，并对其进行修改。
 * 你可以通过 {@link XMPPConnection#addStanzaInterceptor(StanzaListener,
 * xmpp4cj.filter.StanzaFilter)} 方法注册一个消息包监听器作为拦截器。
 * </p>
 *
 * @see XMPPConnection#addAsyncStanzaListener(StanzaListener, xmpp4cj.filter.StanzaFilter)
 */
public interface StanzaListener <: Hashable & Equatable<StanzaListener> {
    /**
     * 处理发送到此消息包监听器的下一个消息包。
     * <p>
     * 如果此监听器是同步的，则由单个线程负责调用所有监听器，因此
     * 实现此方法的代码不应阻塞太长时间。
     * </p>
     *
     * @param packet 要处理的消息包
     * @throws NotConnectedException 如果 XMPP 连接未连接
     * @throws InterruptedException 如果调用线程被中断
     * @throws NotLoggedInException 如果 XMPP 连接未通过身份验证
     */
    func processStanza(packet: Stanza): Unit

    func hashCode(): Int64 {
        0
    }

    operator func ==(that: StanzaListener): Bool {
        match ((this, that)) {
            case (a: Object, b: Object) => refEq(a, b)
            case _ => throw UnsupportedException("StanzaListener must be an Object")
        }
    }
}

/**
 * 简单的StanzaListener
 */
public class SimpleStanzaListener <: StanzaListener {
    /**
     * 初始化 SimpleStanzaListener
     *
     * @param processor 回调接口
     */
    public SimpleStanzaListener(let processor: (Stanza, StanzaListener) -> Unit) {}

    /**
     * 处理发送到此消息包监听器的下一个消息包。
     * <p>
     * 如果此监听器是同步的，则由单个线程负责调用所有监听器，因此
     * 实现此方法的代码不应阻塞太长时间。
     * </p>
     *
     * @param packet 要处理的消息包
     * @throws NotConnectedException 如果 XMPP 连接未连接
     * @throws InterruptedException 如果调用线程被中断
     * @throws NotLoggedInException 如果 XMPP 连接未通过身份验证
     */
    public override func processStanza(packet: Stanza): Unit {
        processor(packet, this)
    }
}
