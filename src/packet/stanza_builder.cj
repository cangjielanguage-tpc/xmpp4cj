/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class StanzaBuilder <: StanzaView & ToString {
    let stanzaIdSource: ?StanzaIdSource
    let stanzaId: ?String

    var _to: ?Jid = None
    var _from: ?Jid = None
    var stanzaError: ?StanzaError = None
    var language: ?String = None
    var extensionElements: MultiMap<QName, ExtensionElement> = MultiMap<QName, ExtensionElement>()

    protected init(other: StanzaBuilder) {
        stanzaIdSource = other.stanzaIdSource
        stanzaId = other.stanzaId
        _to = other._to
        _from = other._from
        stanzaError = other.stanzaError
        language = other.language
        extensionElements = other.extensionElements.clone()
    }

    protected init(stanzaIdSource: StanzaIdSource) {
        this.stanzaIdSource = stanzaIdSource
        this.stanzaId = None
    }

    protected init(stanzaId: ?String) {
        this.stanzaIdSource = None
        this.stanzaId = stanzaId
    }

    protected init(message: Stanza, stanzaId: ?String) {
        this(stanzaId)
        _to = message.getTo()
        _from = message.getFrom()
        stanzaError = message.getError()
        language = message.getLanguage()
        extensionElements = message.cloneExtensionsMap()
    }

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
    public open func to(to: String): StanzaBuilder {
        return this.to(JidCreate.froms(to))
    }

    /**
     * 设置节要发送给谁。
     * XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     */
    public open func to(to: ?Jid): StanzaBuilder {
        this._to = to
        return getThis()
    }

    /**
     * 设置节从谁那里发送。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #froms(Jid)
     */
    public open func froms(froms: String): StanzaBuilder {
        return this.froms(JidCreate.froms(froms))
    }

    /**
     * 设置节从谁那里发送。
     * XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     */
    public open func froms(froms: ?Jid): StanzaBuilder {
        this._from = froms
        return getThis()
    }

    /**
     * 设置这个节的错误。
     *
     * @param stanzaError 要与这个节关联的错误。
     * @return 对这个构建器的引用。
     */
    public open func setError(stanzaError: StanzaError): StanzaBuilder {
        this.stanzaError = stanzaError
        return getThis()
    }

    /**
     * 设置这个节的 xml:lang。
     *
     * @param language 这个节的 xml:lang。
     * @return 对这个构建器的引用。
     */
    public open func setLanguage(language: String): StanzaBuilder {
        this.language = language
        return getThis()
    }

    public open func addExtension(extensionElement: ExtensionElement): StanzaBuilder {
        let key = extensionElement.getQName()
        extensionElements.put(key, extensionElement)
        return getThis()
    }

    public open func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): StanzaBuilder {
        return addExtensions(extensionElements ?? return getThis())
    }

    public open func addExtensions(extensionElements: Collection<ExtensionElement>): StanzaBuilder {
        for (extensionElement in extensionElements) {
            addExtension(extensionElement)
        }
        return getThis()
    }

    public open func overrideExtension(extensionElement: ExtensionElement): StanzaBuilder {
        let key = extensionElement.getQName()
        extensionElements.remove(key)
        extensionElements.put(key, extensionElement)
        return getThis()
    }

    public open func removeExtension(elementName: String, namespace: String): StanzaBuilder {
        let key = QName(namespace, elementName)
        extensionElements.remove(key)
        return getThis()
    }

    public open func removeExtension(extension: ExtensionElement): StanzaBuilder {
        let key = extension.getQName()
        let list = extensionElements.getAll(key)
        list.remove(extension)
        return getThis()
    }

    public open func build(): Stanza

    public open func getThis(): StanzaBuilder

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

    public func willBuildStanzaWithId(): Bool {
        return stanzaIdSource.isSome() || StringUtils.isNotEmpty(stanzaId)
    }

    public func throwIfNoStanzaId(): Unit {
        if (willBuildStanzaWithId()) {
            return
        }
        throw IllegalArgumentException("The builder will not build a stanza with an ID set, although it is required")
    }

    protected open func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit

    public override func toString(): String {
        let builder = ToStringUtil.builderFor("StanzaBuilder").addValue("id", stanzaId).addValue("from", _from ?? None).
            addValue("to", _to ?? None).addValue("language", language).addValue("error", stanzaError ?? None)
        addStanzaSpecificAttributes(builder)
        let iter: Iterator<ToString> = extensionElements.values() |> map {e => e.getQName()}
        builder.add("Extension Elements", iter)
        return builder.build()
    }

    public static func buildMessage(): MessageBuilder {
        return buildMessage(None)
    }

    public static func buildMessage(stanzaId: ?String): MessageBuilder {
        return MessageBuilder(stanzaId)
    }

    public static func buildMessageFrom(message: Message, stanzaId: ?String): MessageBuilder {
        return MessageBuilder(message, stanzaId)
    }

    public static func buildMessageFrom(message: Message, stanzaIdSource: StanzaIdSource): MessageBuilder {
        return MessageBuilder(message, stanzaIdSource)
    }

    public static func buildPresence(): PresenceBuilder {
        return buildPresence(None)
    }

    public static func buildPresence(stanzaId: ?String): PresenceBuilder {
        return PresenceBuilder(stanzaId)
    }

    public static func buildPresenceFrom(presence: Presence, stanzaId: ?String): PresenceBuilder {
        return PresenceBuilder(presence, stanzaId)
    }

    public static func buildPresenceFrom(presence: Presence, stanzaIdSource: StanzaIdSource): PresenceBuilder {
        return PresenceBuilder(presence, stanzaIdSource)
    }

    public static func buildIqData(stanzaId: ?String): IqData {
        return IqData(stanzaId)
    }

    public static func buildResponse<SB>(request: StanzaView, builderFromStanzaId: (?String) -> SB): SB where SB <: StanzaBuilder {
        let responseBuilder = builderFromStanzaId(request.getStanzaId())
        responseBuilder.to(request.getFrom()).froms(request.getTo())
        return responseBuilder
    }
}
