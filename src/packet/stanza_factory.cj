/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class StanzaFactory {
    private let stanzaIdSource: StanzaIdSource

    public func getStanzaIdSource(): StanzaIdSource {
        return stanzaIdSource
    }

    public init(stanzaIdSource: StanzaIdSource) {
        this.stanzaIdSource = stanzaIdSource
    }

    public func buildMessageStanza(): MessageBuilder {
        return MessageBuilder(stanzaIdSource)
    }

    public func buildMessageStanzaFrom(message: Message): MessageBuilder {
        return MessageBuilder(message, stanzaIdSource)
    }

    public func buildPresenceStanza(): PresenceBuilder {
        return PresenceBuilder(stanzaIdSource)
    }

    public func buildPresenceStanzaFrom(presence: Presence): PresenceBuilder {
        return PresenceBuilder(presence, stanzaIdSource)
    }

    public func buildIqData(): IqData {
        return IqData(stanzaIdSource)
    }
}
