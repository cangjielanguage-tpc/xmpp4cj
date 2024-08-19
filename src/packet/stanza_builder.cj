/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class StanzaBuilder <: StanzaView & ToString {
    let stanzaIdSource: ?StanzaIdSource
    let stanzaId: ?String

    var to: ?Jid = None
    var froms: ?Jid = None
    var stanzaError: ?StanzaError = None
    var language: ?String = None
    var extensionElements: MultiMap<QName, ExtensionElement> = MultiMap<QName, ExtensionElement>()

    protected init(other: StanzaBuilder) {
        stanzaIdSource = other.stanzaIdSource
        stanzaId = other.stanzaId
        to = other.to
        froms = other.froms
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
        to = message.getTo()
        froms = message.getFrom()
        stanzaError = message.getError()
        language = message.getLanguage()
        extensionElements = message.cloneExtensionsMap()
    }

    protected init(message: Stanza, stanzaIdSource: StanzaIdSource) {
        this(stanzaIdSource)
        to = message.getTo()
        froms = message.getFrom()
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
     * @see #toMethod(Jid)
     */
    public func toMethod(to: String): StanzaBuilder {
        return toMethod(JidCreate.froms(to))
    }

    /**
     * Sets who the stanza is being sent "to".
     * The XMPP protocol often makes the "to" attribute optional, so it does not always need to be set.
     *
     * @param to who the stanza is being sent to.
     * @return a reference to this builder.
     */
    public func toMethod(to: Jid): StanzaBuilder {
        this.to = to
        return getThis()
    }

    /**
     * Sets who the the stanza is being sent "from".
     *
     * @param from who the stanza is being sent from.
     * @return a reference to this builder.
     * @throws XmppStringprepException if the provided character sequence is not a valid XMPP address.
     * @see #fromMethod(Jid)
     */
    public func fromMethod(froms: String): StanzaBuilder {
        return fromMethod(JidCreate.froms(froms))
    }

    /**
     * Sets who the stanza is being sent "from".
     * The XMPP protocol often makes the "from" attribute optional, so it does not always need to be set.
     *
     * @param from who the stanza is being sent from.
     * @return a reference to this builder.
     */
    public func fromMethod(froms: Jid): StanzaBuilder {
        this.froms = froms
        return getThis()
    }

    /**
     * Sets the error for this stanza.
     *
     * @param stanzaError the error to associate with this stanza.
     * @return a reference to this builder.
     */
    public func setError(stanzaError: StanzaError): StanzaBuilder {
        this.stanzaError = stanzaError
        return getThis()
    }

    /**
     * Sets the xml:lang for this stanza.
     *
     * @param language the xml:lang of this stanza.
     * @return a reference to this builder.
     */
    public func setLanguage(language: String): StanzaBuilder {
        this.language = language
        return getThis()
    }

    public func addExtension(extensionElement: ExtensionElement): StanzaBuilder {
        let key = extensionElement.getQName()
        extensionElements.put(key, extensionElement)
        return getThis()
    }

    public func addOptExtensions(extensionElements: Collection<ExtensionElement>): StanzaBuilder {
        return addExtensions(extensionElements)
    }

    public func addExtensions(extensionElements: Collection<ExtensionElement>): StanzaBuilder {
        for (extensionElement in extensionElements) {
            addExtension(extensionElement)
        }
        return getThis()
    }

    public func overrideExtension(extensionElement: ExtensionElement): StanzaBuilder {
        let key = extensionElement.getQName()
        extensionElements.remove(key)
        extensionElements.put(key, extensionElement)
        return getThis()
    }

    public func removeExtension(elementName: String, namespace: String): StanzaBuilder {
        let key = QName(namespace, elementName)
        extensionElements.remove(key)
        return getThis()
    }

    public func removeExtension(extension: ExtensionElement): StanzaBuilder {
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
        return to
    }

    public override func getFrom(): ?Jid {
        return froms
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

    // public func getExtensionElements(): MultiMap<QName, ExtensionElement> {
    //     extensionElements
    // }

    public override func getExtensions(qnameFrom: ClassId): ArrayList<ExtensionElement> {
        return XmppElementUtil.getElementsFrom(extensionElements, qnameFrom)
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
        let builder = ToStringUtil.builderFor("StanzaBuilder").addValue("id", stanzaId).addValue("from", froms ?? None).
            addValue("to", to ?? None).addValue("language", language).addValue("error", stanzaError ?? None)
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
        responseBuilder.toMethod(request.getFrom().getOrThrow().toString()).fromMethod(
            request.getTo().getOrThrow().toString())
        return responseBuilder
    }
}
