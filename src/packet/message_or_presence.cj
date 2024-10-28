/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**  
 * {@code MessageOrPresence} 是一个抽象类，表示可以作为消息或存在状态的 XMPP 信令。
 * <p>
 * 此类扩展自 {@link Stanza}，并为消息（Message）和存在状态（Presence）提供了公共基础。
 * 通常被具体的消息或存在状态实现类继承。
 * </p>
 */
public abstract class MessageOrPresence <: Stanza {
    /**  
     * 使用指定的 {@code StanzaBuilder} 初始化 {@code MessageOrPresence} 实例。
     *
     * @param stanzaBuilder 用于构建信令的 {@code StanzaBuilder} 实例。
     */
    protected init(stanzaBuilder: StanzaBuilder) {
        super(stanzaBuilder)
    }

    /**  
     * 使用指定的 {@code Stanza} 复制构造一个 {@code MessageOrPresence} 实例。
     *
     * @param other 另一个 {@code Stanza} 实例。
     */
    protected init(other: Stanza) {
        super(other)
    }

    /**  
     * 返回一个构造器来构建当前的消息或存在状态。
     *
     * @return 当前消息或存在状态的构造器。
     */
    public func asBuilder(): MessageOrPresenceBuilder

    /**  
     * 使用指定的标识符返回一个构造器来构建当前的消息或存在状态。
     *
     * @param id 消息或存在状态的标识符。
     * @return 带有指定标识符的构造器。
     */
    public func asBuilder(id: String): MessageOrPresenceBuilder

    /**
     * 使用指定的{@link StanzaFactory}构建{@link PresenceBuilder}
     *
     * @param stanzaFactory 来自于{@link XMPPConnection#getStanzaFactory()}
     * @return Presence构造器
     */
    public func asBuilder(stanzaFactory: StanzaFactory): MessageOrPresenceBuilder
}

/**  
 * {@code MessageOrPresenceBuilder} 是一个抽象类，用于构建 {@link MessageOrPresence} 实例的构建器。
 * <p>
 * 此类扩展自 {@link StanzaBuilder}，提供用于特定类型的 XMPP 消息或存在状态的创建方法。
 * </p>
 */
public abstract class MessageOrPresenceBuilder <: StanzaBuilder {
    /**  
     * 使用给定的 <code>Stanza</code> 和 <code>StanzaIdSource</code> 初始化构建器。
     *
     * @param stanza 要构建的基于的 {@code Stanza} 实例。
     * @param stanzaIdSource stanza ID 源。
     */
    protected init(stanza: Stanza, stanzaIdSource: StanzaIdSource) {
        super(stanza, stanzaIdSource)
    }

    /**  
     * 使用给定的 <code>Stanza</code> 和指定的 stanza ID 初始化构建器。
     *
     * @param stanza 要构建的基于的 {@code Stanza} 实例。
     * @param stanzaId 指定的 stanza ID。
     */
    protected init(stanza: Stanza, stanzaId: ?String) {
        super(stanza, stanzaId)
    }

    /**  
     * 使用指定的 <code>StanzaIdSource</code> 初始化构建器。
     *
     * @param stanzaIdSource stanza ID 源。
     */
    protected init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    /**  
     * 使用指定的 stanza ID 初始化构建器。
     *
     * @param stanzaId 指定的 stanza ID。
     */
    protected init(stanzaId: ?String) {
        super(stanzaId)
    }

    /**  
     * 构建并返回一个新的 {@code MessageOrPresence} 实例。
     *
     * @return 构建的 {@code MessageOrPresence} 对象。
     */
    public open override func build(): MessageOrPresence
}
