/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**  
 * 抽象类 StanzaBuilder，用于构建 XMPP 的 Stanza（消息、存在状态和 IQ 数据）。
 */
public abstract class StanzaBuilder <: StanzaView & ToString {
    let stanzaIdSource: ?StanzaIdSource // 消息 ID 源  

    let stanzaId: ?String // 消息 ID  

    var _to: ?Jid = None // 消息接收者 

    var _from: ?Jid = None // 消息发送者  

    var stanzaError: ?StanzaError = None // 消息错误信息  

    var language: ?String = None // 语言设置  

    var extensionElements: MultiMap<QName, ExtensionElement> = MultiMap<QName, ExtensionElement>() // 扩展元素  

    /**  
     * 通过另一个StanzaBuilder对象构造当前对象。
     *
     * @param other 其他StanzaBuilder对象。
     */
    protected init(other: StanzaBuilder) {
        stanzaIdSource = other.stanzaIdSource
        stanzaId = other.stanzaId
        _to = other._to
        _from = other._from
        stanzaError = other.stanzaError
        language = other.language
        extensionElements = other.extensionElements.clone()
    }

    /**  
     * 通过StanzaIdSource对象构造当前对象。
     *
     * @param stanzaIdSource StanzaIdSource对象。
     */
    protected init(stanzaIdSource: StanzaIdSource) {
        this.stanzaIdSource = stanzaIdSource
        this.stanzaId = None
    }

    /**  
     * 通过ID构造当前对象。
     *
     * @param stanzaId 消息ID。
     */
    protected init(stanzaId: ?String) {
        this.stanzaIdSource = None
        this.stanzaId = StringUtils.requireNullOrNotEmpty(stanzaId, "Stanza ID must not be the empty String")
    }

    /**  
     * 通过Stanza对象和ID构造当前对象。
     *
     * @param message Stanza对象。
     * @param stanzaId 消息ID。
     */
    protected init(message: Stanza, stanzaId: ?String) {
        this(stanzaId)
        _to = message.getTo()
        _from = message.getFrom()
        stanzaError = message.getError()
        language = message.getLanguage()
        extensionElements = message.cloneExtensionsMap()
    }

    /**  
     * 通过Stanza对象和StanzaIdSource对象构造当前对象。
     *
     * @param message Stanza对象。
     * @param stanzaIdSource StanzaIdSource对象。
     */
    protected init(message: Stanza, stanzaIdSource: StanzaIdSource) {
        this(stanzaIdSource)
        _to = message.getTo()
        _from = message.getFrom()
        stanzaError = message.getError()
        language = message.getLanguage()
        extensionElements = message.cloneExtensionsMap()
    }

    /**
     * 设置节的接收方地址。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #to(Jid)
     */
    public open func to(to: String): This {
        return this.to(JidCreate.froms(to))
    }

    /**
     * 设置节要发送给谁。
     * XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     */
    public open func to(to: ?Jid): This {
        this._to = to
        return this
    }

    /**
     * 设置节从谁那里发送。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #froms(Jid)
     */
    public open func froms(froms: String): This {
        return this.froms(JidCreate.froms(froms))
    }

    /**
     * 设置节从谁那里发送。
     * XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     */
    public open func froms(froms: ?Jid): This {
        this._from = froms
        return this
    }

    /**
     * 设置这个节的错误。
     *
     * @param stanzaError 要与这个节关联的错误。
     * @return 对这个构建器的引用。
     */
    public open func setError(stanzaError: ?StanzaError): This {
        this.stanzaError = stanzaError
        return this
    }

    /**
     * 设置这个节的 xml:lang。
     *
     * @param language 这个节的 xml:lang。
     * @return 对这个构建器的引用。
     */
    public open func setLanguage(language: ?String): This {
        this.language = language
        return this
    }

    /**  
     * 添加子元素到构建器中。
     *
     * @param extensionElement 要添加的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public open func addExtension(extensionElement: ExtensionElement): This {
        let key = extensionElement.getQName()
        extensionElements.put(key, extensionElement)
        return this
    }

    /**  
     * 添加可选的多个子元素。
     *
     * @param extensionElements 要添加的子元素集（可以为空，但不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public open func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): This {
        return addExtensions(extensionElements ?? return this)
    }

    /**  
     * 添加多个子元素。
     *
     * @param extensionElements 要添加的子元素集（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public open func addExtensions(extensionElements: Collection<ExtensionElement>): This {
        for (extensionElement in extensionElements) {
            addExtension(extensionElement)
        }
        return this
    }

    /**  
     * 替换现有的子元素。
     *
     * @param extensionElement 要替换的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public open func overrideExtension(extensionElement: ExtensionElement): This {
        let key = extensionElement.getQName()
        extensionElements.remove(key)
        extensionElements.put(key, extensionElement)
        return this
    }

    /**  
     * 移除指定的子元素。
     *
     * @param elementName 要移除的元素名称
     * @param namespace 该元素的命名空间
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public open func removeExtension(elementName: String, namespace: String): This {
        let key = QName(namespace, elementName)
        extensionElements.remove(key)
        return this
    }

    /**  
     * 移除指定的子元素。
     *
     * @param extension 要移除的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public open func removeExtension(extension: ExtensionElement): This {
        let key = extension.getQName()
        let list = extensionElements.getAll(key)
        list.removeValue(extension)
        return this
    }

    /**  
     * 构建并返回一个新的 Stanza 实例。
     *
     * @return 新建的 Stanza 实例
     */
    public open func build(): Stanza

    public override func getStanzaId(): ?String {
        return stanzaId
    }

    public override func getTo(): ?Jid {
        return _to
    }

    public override func getFrom(): ?Jid {
        return _from
    }

    public override func getLanguage(): ?String {
        return language
    }

    public override func getError(): ?StanzaError {
        return stanzaError
    }

    public override func getExtension(qname: QName): ?ExtensionElement {
        return extensionElements.getFirst(qname)
    }

    public override func getExtensions(): ArrayList<ExtensionElement> {
        return extensionElements.values()
    }

    public override func getExtensions(qname: QName): ArrayList<ExtensionElement> {
        return extensionElements.getAll(qname)
    }

    public override func getExtensionsByType(extensionElementClass: ClassId): ArrayList<ExtensionElement> {
        return XmppElementUtil.getElementsFrom(extensionElements, extensionElementClass)
    }

    /**  
     * 判断是否将构建的 Stanza 设置 ID。
     *
     * @return 如果设置了 ID 返回 true，否则返回 false
     */
    public func willBuildStanzaWithId(): Bool {
        return stanzaIdSource.isSome() || StringUtils.isNotEmpty(stanzaId)
    }

    /**  
     * 如果没有设置 Stanza ID 则抛出异常。
     *
     * @throws IllegalArgumentException 如果没有设置 Stanza ID
     */
    public func throwIfNoStanzaId(): Unit {
        if (willBuildStanzaWithId()) {
            return
        }
        throw IllegalArgumentException("The builder will not build a stanza with an ID set, although it is required")
    }

    /**  
     * 添加特定于 Stanza 的属性。
     *
     * @param builder 用于构建字符串的构建器。
     */
    protected open func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit

    public override func toString(): String {
        let builder = ToStringUtil
            .builderFor("StanzaBuilder")
            .addValue("id", stanzaId)
            .addValue("from", _from ?? None)
            .addValue("to", _to ?? None)
            .addValue("language", language)
            .addValue("error", stanzaError ?? None)
        addStanzaSpecificAttributes(builder)
        let iter: Iterator<ToString> = extensionElements.values() |> map {e => e.getQName()}
        builder.add("Extension Elements", iter)
        return builder.build()
    }

    /**  
     * 创建一个空的MessageBuilder对象。
     *
     * @return MessageBuilder对象。
     */
    public static func buildMessage(): MessageBuilder {
        return buildMessage(None)
    }

    /**  
     * 通过入参ID创建一个MessageBuilder对象。
     *
     * @param stanzaId ID。
     * @return MessageBuilder对象。
     */
    public static func buildMessage(stanzaId: ?String): MessageBuilder {
        return MessageBuilder(stanzaId)
    }

    /**  
     * 通过ID和内容创建一个MessageBuilder对象。
     *
     * @param message 内容。
     * @param stanzaId ID。
     * @return MessageBuilder对象。
     */
    public static func buildMessageFrom(message: Message, stanzaId: ?String): MessageBuilder {
        return MessageBuilder(message, stanzaId)
    }

    /**  
     * 通过ID资源和内容创建一个MessageBuilder对象。
     *
     * @param message 内容。
     * @param stanzaIdSource ID资源。
     * @return MessageBuilder对象。
     */
    public static func buildMessageFrom(message: Message, stanzaIdSource: StanzaIdSource): MessageBuilder {
        return MessageBuilder(message, stanzaIdSource)
    }

    /**  
     * 创建一个空的PresenceBuilder对象。
     *
     * @return PresenceBuilder对象。
     */
    public static func buildPresence(): PresenceBuilder {
        return buildPresence(None)
    }

    /**  
     * 通过入参ID创建一个PresenceBuilder对象。
     *
     * @param stanzaId ID。
     * @return PresenceBuilder对象。
     */
    public static func buildPresence(stanzaId: ?String): PresenceBuilder {
        return PresenceBuilder(stanzaId)
    }

    /**  
     * 通过ID和Presence对象创建一个PresenceBuilder对象。
     *
     * @param presence Presence对象。
     * @param stanzaId ID。
     * @return PresenceBuilder对象。
     */
    public static func buildPresenceFrom(presence: Presence, stanzaId: ?String): PresenceBuilder {
        return PresenceBuilder(presence, stanzaId)
    }

    /**  
     * 通过ID资源和Presence对象创建一个PresenceBuilder对象。
     *
     * @param presence Presence对象。
     * @param stanzaIdSource ID资源。
     * @return PresenceBuilder对象。
     */
    public static func buildPresenceFrom(presence: Presence, stanzaIdSource: StanzaIdSource): PresenceBuilder {
        return PresenceBuilder(presence, stanzaIdSource)
    }

    /**  
     * 通过入参ID创建一个IqData对象。
     *
     * @param stanzaId ID资源。。
     * @return IqData对象。
     */
    public static func buildIqData(stanzaId: ?String): IqData {
        return IqData(stanzaId)
    }

    /**  
     * 通过入参创建一个泛型对象，泛型对象是StanzaBuilder的子类。
     *
     * @param request StanzaView对象
     * @param builderFromStanzaId 方法
     * @return 泛型对象
     */
    public static func buildResponse<SB>(request: StanzaView, builderFromStanzaId: (?String) -> SB): SB where SB <: StanzaBuilder {
        let responseBuilder = builderFromStanzaId(request.getStanzaId())
        responseBuilder.to(request.getFrom()).froms(request.getTo())
        return responseBuilder
    }
}
