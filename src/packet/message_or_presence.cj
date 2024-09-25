/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class MessageOrPresence <: Stanza {
    protected init(stanzaBuilder: StanzaBuilder) {
        super(stanzaBuilder)
    }

    protected init(other: Stanza) {
        super(other)
    }

    public func asBuilder(): MessageOrPresenceBuilder

    public func asBuilder(id: String): MessageOrPresenceBuilder

    // public func asBuilder(connection: XMPPConnection): MessageOrPresenceBuilder
}

public abstract class MessageOrPresenceBuilder <: StanzaBuilder {
    protected init(stanza: Stanza, stanzaIdSource: StanzaIdSource) {
        super(stanza, stanzaIdSource)
    }

    protected init(stanza: Stanza, stanzaId: ?String) {
        super(stanza, stanzaId)
    }

    protected init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    protected init(stanzaId: ?String) {
        super(stanzaId)
    }

    public open override func build(): MessageOrPresence
}
