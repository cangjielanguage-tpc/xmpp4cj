/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * {@code MessageBuilder} 类用于构建 XMPP 消息（Message）对象的方便构建器。
 * <p>
 * 该类为 {@link Message} 对象提供了灵活的构建选项，包括设置消息类型、主体和主题等属性。
 * 它支持从现有的 {@code Message} 实例中复制设置，并提供了一系列方法用于设置消息的不同部分。
 * </p>
 */
public class MessageBuilder <: MessageOrPresenceBuilder & MessageView {
    /**
     * 表示一个空的 {@code MessageBuilder} 实例。
     */
    static let EMPTY = MessageBuilder(RandomStringStanzaIdSource {=> None})

    var typ: ?MessageType = None // 消息类型  

    /**
     * 使用现有的消息和指定的 stanza ID 初始化 {@code MessageBuilder} 实例。
     *
     * @param message 要复制属性的 {@code Message} 实例。
     * @param stanzaId 指定的 stanza ID。
     */
    init(message: Message, stanzaId: ?String) {
        super(message, stanzaId)
        copyFromMessage(message)
    }

    /**
     * 使用现有的消息和指定的 stanza ID 源初始化 {@code MessageBuilder} 实例。
     *
     * @param message 要复制属性的 {@code Message} 实例。
     * @param stanzaIdSource 指定的 stanza ID 源。
     */
    init(message: Message, stanzaIdSource: StanzaIdSource) {
        super(message, stanzaIdSource)
        copyFromMessage(message)
    }

    /**
     * 使用指定的 stanza ID 源初始化 {@code MessageBuilder} 实例。
     *
     * @param stanzaIdSource 指定的 stanza ID 源。
     */
    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    /**
     * 使用指定的 stanza ID 初始化 {@code MessageBuilder} 实例。
     *
     * @param stanzaId 指定的 stanza ID。
     */
    init(stanzaId: ?String) {
        super(stanzaId)
    }

    /**
     * 从现有的消息中复制属性。
     *
     * @param message 要复制属性的 {@code Message} 实例。
     */
    private func copyFromMessage(message: Message): Unit {
        typ = message.getType()
    }

    /**
     * 添加特定于 Stanza 的属性。
     *
     * @param builder 用于构建字符串的构建器。
     */
    protected override func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit {
        builder.addValue("type", typ?.toString())
    }

    /**
     * 设置消息类型。
     *
     * @param type 要设置的 {@code Message.Type} 类型。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func ofType(typ: MessageType): This {
        this.typ = typ
        return this
    }

    /**
     * 设置消息线程 ID。
     *
     * @param thread 消息线程 ID。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func setThread(thread: String): This {
        return setThread(thread, None)
    }

    /**
     * 设置消息线程和父线程 ID。
     *
     * @param thread 消息线程 ID。
     * @param parent 父线程 ID。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func setThread(thread: String, parent: ?String): This {
        addExtension(MessageThread(thread, parent))
        return this
    }

    /**
     * 设置消息的主题。主题是消息内容的简短描述。
     *
     * @param subject 消息的主题。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func setSubject(subject: String): This {
        return addSubject(None, subject)
    }

    /**
     * 添加带有对应语言的主题。
     *
     * @param language 主题的语言。
     * @param subject 要添加到消息的主题。
     * @return 当前 {@code MessageBuilder} 的引用。
     * @throws NullPointerException 如果主题为 {@code null}。
     */
    public func addSubject(languageStr: ?String, subject: String): This {
        let language = StringUtils.requireNullOrNotEmpty(languageStr, "language must be None or not empty")
        for (currentSubject in getExtensionsByType(MessageSubject.getClassId())) {
            if (StringUtils.nullSafeCharSequenceEquals(language, currentSubject.getLanguage())) {
                throw IllegalArgumentException("Subject with the language ${language} already exists")
            }
        }
        let messageSubject = MessageSubject(language, subject)
        addExtension(messageSubject)
        return this
    }

    /**
     * 设置消息正文。
     *
     * @param body 消息正文。
     * @return 当前 {@code MessageBuilder} 的引用。
     * @see #setBody(String)
     */
    public func setBody(body: String): This {
        return addBody(None, body)
    }

    /**
     * 添加带有对应语言的消息正文。
     *
     * @param language 正文的语言。
     * @param body 要添加的消息正文。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func addBody(languageStr: ?String, body: String): This {
        let language = StringUtils.requireNullOrNotEmpty(languageStr, "language must be None or not empty")
        for (currentBody in getExtensionsByType(MessageBody.getClassId())) {
            if (StringUtils.nullSafeCharSequenceEquals(language, currentBody.getLanguage())) {
                throw IllegalArgumentException("Body with the language ${language} already exists")
            }
        }
        let messageBody = MessageBody(language, body)
        addExtension(messageBody)
        return this
    }

    /**
     * 构建并返回一个新的 {@code Message} 实例。
     *
     * @return 构建的 {@code Message} 对象。
     */
    public override func build(): Message {
        return Message(this)
    }

    public override func getType(): ?MessageType {
        return typ
    }
}
