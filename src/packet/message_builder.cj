/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
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
    public func ofType(typ: MessageType): MessageBuilder {
        this.typ = typ
        return getThis()
    }

    /**  
     * 设置消息线程 ID。
     *
     * @param thread 消息线程 ID。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func setThread(thread: String): MessageBuilder {
        return setThread(thread, None)
    }

    /**  
     * 设置消息线程和父线程 ID。
     *
     * @param thread 消息线程 ID。
     * @param parent 父线程 ID。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func setThread(thread: String, parent: ?String): MessageBuilder {
        addExtension(MessageThread(thread, parent))
        return getThis()
    }

    /**  
     * 设置消息的主题。主题是消息内容的简短描述。
     *
     * @param subject 消息的主题。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func setSubject(subject: String): MessageBuilder {
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
    public func addSubject(languageStr: ?String, subject: String): MessageBuilder {
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
    public func setBody(body: String): MessageBuilder {
        return addBody(None, body)
    }

    /**  
     * 添加带有对应语言的消息正文。
     *
     * @param language 正文的语言。
     * @param body 要添加的消息正文。
     * @return 当前 {@code MessageBuilder} 的引用。
     */
    public func addBody(languageStr: ?String, body: String): MessageBuilder {
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

    /**  
     * 获取当前类的实例。
     *
     * @return 当前类实例
     */
    public override func getThis(): MessageBuilder {
        return this
    }

    /**
     * 设置节的接收方地址。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #to(Jid)
     */
    public override func to(to: String): MessageBuilder {
        super.to(to)
        getThis()
    }

    /**
     * 设置节要发送给谁。
     * XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     */
    public override func to(to: ?Jid): MessageBuilder {
        super.to(to)
        getThis()
    }

    /**
     * 设置节从谁那里发送。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #froms(Jid)
     */
    public override func froms(froms: String): MessageBuilder {
        super.froms(froms)
        getThis()
    }

    /**
     * 设置节从谁那里发送。
     * XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     */
    public override func froms(froms: ?Jid): MessageBuilder {
        super.froms(froms)
        getThis()
    }

    /**
     * 设置这个节的错误。
     *
     * @param stanzaError 要与这个节关联的错误。
     * @return 对这个构建器的引用。
     */
    public override func setError(stanzaError: ?StanzaError): MessageBuilder {
        super.setError(stanzaError)
        getThis()
    }

    /**
     * 设置这个节的 xml:lang。
     *
     * @param language 这个节的 xml:lang。
     * @return 对这个构建器的引用。
     */
    public override func setLanguage(language: ?String): MessageBuilder {
        super.setLanguage(language)
        getThis()
    }

    /**  
     * 添加子元素到构建器中。
     *
     * @param extensionElement 要添加的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addExtension(extensionElement: ExtensionElement): MessageBuilder {
        super.addExtension(extensionElement)
        getThis()
    }

    /**  
     * 添加可选的多个子元素。
     *
     * @param extensionElements 要添加的子元素集（可以为空，但不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): MessageBuilder {
        super.addOptExtensions(extensionElements)
        getThis()
    }

    /**  
     * 添加多个子元素。
     *
     * @param extensionElements 要添加的子元素集（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addExtensions(extensionElements: Collection<ExtensionElement>): MessageBuilder {
        super.addExtensions(extensionElements)
        getThis()
    }

    /**  
     * 替换现有的子元素。
     *
     * @param extensionElement 要替换的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func overrideExtension(extensionElement: ExtensionElement): MessageBuilder {
        super.overrideExtension(extensionElement)
        getThis()
    }

    /**  
     * 移除指定的子元素。
     *
     * @param elementName 要移除的元素名称
     * @param namespace 该元素的命名空间
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func removeExtension(elementName: String, namespace: String): MessageBuilder {
        super.removeExtension(elementName, namespace)
        getThis()
    }

    /**  
     * 移除指定的子元素。
     *
     * @param extension 要移除的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func removeExtension(extension: ExtensionElement): MessageBuilder {
        super.removeExtension(extension)
        getThis()
    }
}
