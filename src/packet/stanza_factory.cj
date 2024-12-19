/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * Stanza工厂类
 */
public class StanzaFactory {
    private let stanzaIdSource: StanzaIdSource // 用于生成 Stanza ID 的源

    /**
     * 获取 StanzaIdSource
     *
     * @return StanzaIdSource 对象
     */
    public func getStanzaIdSource(): StanzaIdSource {
        return stanzaIdSource
    }

    /**
     * 构造函数，初始化 StanzaFactory
     *
     * @param stanzaIdSource 用于生成 Stanza ID 的源
     */
    public init(stanzaIdSource: StanzaIdSource) {
        this.stanzaIdSource = stanzaIdSource
    }

    /**
     * 创建一个新的消息 Stanza 构建器
     *
     * @return 消息构建器实例
     */
    public func buildMessageStanza(): MessageBuilder {
        return MessageBuilder(stanzaIdSource)
    }

    /**
     * 从给定的消息对象创建一个新的消息 Stanza 构建器
     *
     * @param message 源消息对象
     * @return 消息构建器实例
     */
    public func buildMessageStanzaFrom(message: Message): MessageBuilder {
        return MessageBuilder(message, stanzaIdSource)
    }

    /**
     * 创建一个新的状态（Presence）Stanza 构建器
     *
     * @return 状态构建器实例
     */
    public func buildPresenceStanza(): PresenceBuilder {
        return PresenceBuilder(stanzaIdSource)
    }

    /**
     * 从给定的状态对象创建一个新的状态（Presence）Stanza 构建器
     *
     * @param presence 源状态对象
     * @return 状态构建器实例
     */
    public func buildPresenceStanzaFrom(presence: Presence): PresenceBuilder {
        return PresenceBuilder(presence, stanzaIdSource)
    }

    /**
     * 创建一个新的 IQ 数据对象
     *
     * @return IQ 数据对象
     */
    public func buildIqData(): IqData {
        return IqData(stanzaIdSource)
    }
}
