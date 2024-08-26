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
     * Set the recipent address of the stanza.
     *
     * @param to whoe the stanza is being sent to.
     * @return a reference to this builder.
     * @throws XmppStringprepException if the provided character sequence is not a valid XMPP address.
     * @see #to(Jid)
     */
    public open func to(to: String): StanzaBuilder {
        return this.to(JidCreate.froms(to))
    }

    /**
     * Sets who the stanza is being sent "to".
     * The XMPP protocol often makes the "to" attribute optional, so it does not always need to be set.
     *
     * @param to who the stanza is being sent to.
     * @return a reference to this builder.
     */
    public open func to(to: ?Jid): StanzaBuilder {
        this._to = to
        return getThis()
    }

    /**
     * Sets who the the stanza is being sent "from".
     *
     * @param froms who the stanza is being sent from.
     * @return a reference to this builder.
     * @throws XmppStringprepException if the provided character sequence is not a valid XMPP address.
     * @see #froms(Jid)
     */
    public open func froms(froms: String): StanzaBuilder {
        return this.froms(JidCreate.froms(froms))
    }

    /**
     * Sets who the stanza is being sent "from".
     * The XMPP protocol often makes the "from" attribute optional, so it does not always need to be set.
     *
     * @param froms who the stanza is being sent from.
     * @return a reference to this builder.
     */
    public open func froms(froms: ?Jid): StanzaBuilder {
        this._from = froms
        return getThis()
    }

    /**
     * Sets the error for this stanza.
     *
     * @param stanzaError the error to associate with this stanza.
     * @return a reference to this builder.
     */
    public open func setError(stanzaError: StanzaError): StanzaBuilder {
        this.stanzaError = stanzaError
        return getThis()
    }

    /**
     * Sets the xml:lang for this stanza.
     *
     * @param language the xml:lang of this stanza.
     * @return a reference to this builder.
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

    public open func addOptExtensions(extensionElements: Collection<ExtensionElement>): StanzaBuilder {
        return addExtensions(extensionElements)
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
