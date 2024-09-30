/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * Provides a mechanism to listen for packets that pass a specified filter.
 * This allows event-style programming -- every time a new stanza is found,
 * the {@link #processStanza(Stanza)} method will be called. This is the
 * opposite approach to the functionality provided by a {@link StanzaCollector}
 * which lets you block while waiting for results.
 * <p>
 * Additionally you are able to intercept Packets that are going to be send and
 * make modifications to them. You can register a PacketListener as interceptor
 * by using {@link XMPPConnection#addStanzaInterceptor(StanzaListener,
 * xmpp4cj.filter.StanzaFilter)}
 * </p>
 *
 * @see XMPPConnection#addAsyncStanzaListener(StanzaListener, xmpp4cj.filter.StanzaFilter)
 */
public interface StanzaListener <: Hashable & Equatable<StanzaListener> {
    /**
     * Process the next stanza sent to this stanza listener.
     * <p>
     * If this listener is synchronous, then a single thread is responsible for invoking all listeners, so
     * it's very important that implementations of this method not block
     * for any extended period of time.
     * </p>
     *
     * @param packet the stanza to process.
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws InterruptedException if the calling thread was interrupted.
     * @throws NotLoggedInException if the XMPP connection is not authenticated.
     */
    func processStanza(packet: Stanza): Unit
    func hashCode(): Int64 {
        0
    }
    operator func ==(that: StanzaListener): Bool {
        EqualsUtil.equals(this, that)
    }
}

public class SimpleStanzaListener <: StanzaListener {
    public SimpleStanzaListener(let processor: (Stanza, StanzaListener) -> Unit) {}
    public override func processStanza(packet: Stanza): Unit {
        processor(packet, this)
    }
}
