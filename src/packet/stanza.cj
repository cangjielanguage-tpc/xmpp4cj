/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Base class for XMPP Stanzas.
 * <p>
 * Every stanza has a unique ID (which is automatically generated, but can be overridden). Stanza
 * IDs are required for IQ stanzas and recommended for presence and message stanzas. Optionally, the
 * "to" and "from" fields can be set.
 * </p>
 * <p>
 * XMPP Stanzas are {@link Message}, {@link IQ} and {@link Presence}. Which therefore subclass this
 * class. <b>If you think you need to subclass this class, then you are doing something wrong.</b>
 * </p>
 * <p>
 * Use {@link StanzaBuilder} to construct a stanza instance. All instance mutating methods of this
 * class are deprecated, although not all of them are currently marked as such, and must not be used.
 * </p>
 * @see <a href="xmpp/org/rfcs/rfc6120.html#stanzas">RFC 6120 § 8. XML Stanzas</a>
 */
public abstract class Stanza <: StanzaView & TopLevelStreamElement {
    public static let TEXT = "text"
    public static let ITEM = "item"
    protected static let DEFAULT_LANGUAGE = "en" // TODO

    /*
     * Assume that all stanzas Xmpp handles are in the client namespace,
     * since Xmpp4cj is an XMPP client library.
     * We can change this behavior later if it is required.
     */
    private let namespace = StreamOpen.CLIENT_NAMESPACE
    private let extensionElements: MultiMap<QName, ExtensionElement>
    private let usedStanzaIdSource: ?StanzaIdSource

    private var id: ?String
    private var to: ?Jid = None
    private var froms: ?Jid = None
    private var error: ?StanzaError = None

    /**
     * Optional value of the 'xml:lang' attribute of the outermost element of
     * the stanza.
     * <p>
     * Such an attribute is defined for all stanza types. For IQ, see for
     * example XEP-50 3.7:
     * "The requester SHOULD provide its locale information using the "xml:lang
     * " attribute on either the &lt;iq/&gt; (RECOMMENDED) or &lt;command/&gt; element."
     * </p>
     */
    protected var language: ?String = None

    protected init() {
        extensionElements = MultiMap<QName, ExtensionElement>()
        usedStanzaIdSource = None
        id = StandardStanzaIdSource.DEFAULT.getNewStanzaId()
    }

    protected init(stanzaBuilder: StanzaBuilder) {
        super()
        if (let Some(stanzaIdSource) <- stanzaBuilder.stanzaIdSource) {
            id = stanzaIdSource.getNewStanzaId()
            if (!StringUtils.isNullOrNotEmpty(id)) {
                throw IllegalArgumentException("${id}")
            }
            usedStanzaIdSource = stanzaIdSource
        } else {
            id = stanzaBuilder.stanzaId
            usedStanzaIdSource = None
        }
        to = stanzaBuilder._to
        froms = stanzaBuilder._from
        error = stanzaBuilder.stanzaError
        language = stanzaBuilder.language
        extensionElements = stanzaBuilder.extensionElements.clone()
    }

    protected init(p: Stanza) {
        usedStanzaIdSource = p.usedStanzaIdSource
        id = p.getStanzaId()
        to = p.getTo()
        froms = p.getFrom()
        error = p.error
        extensionElements = p.extensionElements.clone()
    }

    public override func getStanzaId(): ?String {
        return id
    }

    /**
     * Sets the unique ID of the packet. To indicate that a stanza has no id
     * pass <code>None</code> as the packet's id value.
     *
     * @param id the unique ID for the packet.
     */
    public open func setStanzaId(id: ?String): Unit {
        if (id.isSome()) {
            StringUtils.requireNotNullNorEmpty(id, "id must either be None or not the empty String")
        }
        this.id = id
    }

    /**
     * Check if this stanza has an ID set.
     *
     * @return true if the stanza ID is set, false otherwise.
     */
    public func hasStanzaIdSet(): Bool {
        return id.isSome()
    }

    /**
     * Throws an {@link IllegalArgumentException} if this stanza has no stanza ID set.
     *
     * @throws IllegalArgumentException if this stanza has no stanza ID set.
     */
    public func throwIfNoStanzaId(): Unit {
        if (hasStanzaIdSet()) {
            return
        }
        throw IllegalArgumentException("The stanza has no RFC stanza ID set, although one is required")
    }

    /**
     * Ensure that a stanza ID is set.
     *
     * @return the stanza ID.
     */
    protected open func setNewStanzaId(): ?String {
        if (usedStanzaIdSource.isSome()) {
            id = usedStanzaIdSource.getOrThrow().getNewStanzaId()
        } else {
            id = StandardStanzaIdSource.DEFAULT.getNewStanzaId()
        }
        return getStanzaId()
    }

    public override func getTo(): ?Jid {
        return to
    }

    /**
     * Sets who the packet is being sent "to". The XMPP protocol often makes
     * the "to" attribute optional, so it does not always need to be set.
     *
     * @param to who the packet is being sent to.
     */
    public open func setTo(to: ?Jid): Unit {
        this.to = to
    }

    public override func getFrom(): ?Jid {
        return froms
    }

    /**
     * Sets who the packet is being sent "from". The XMPP protocol often
     * makes the "from" attribute optional, so it does not always need to
     * be set.
     *
     * @param from who the packet is being sent to.
     */
    public open func setFrom(froms: ?Jid): Unit {
        this.froms = froms
    }

    public override func getError(): ?StanzaError {
        return error
    }

    /**
     * Sets the error for this stanza.
     *
     * @param stanzaError the error that this stanza carries and hence signals.
     */
    public open func setError(stanzaError: ?StanzaError): Unit {
        error = stanzaError
    }

    public override func getLanguage(): ?String {
        return language
    }

    public override func getExtensions(): ArrayList<ExtensionElement> {
        synchronized(extensionElements.lock) {
            return extensionElements.values()
        }
    }

    public func getExtensionsMap(): MultiMap<QName, ExtensionElement> {
        return cloneExtensionsMap()
    }

    func cloneExtensionsMap(): MultiMap<QName, ExtensionElement> {
        synchronized(extensionElements.lock) {
            return extensionElements.clone()
        }
    }

    /**
     * Return a list of all extensions with the given element name <em>and</em> namespace.
     * <p>
     * Changes to the returned set will update the stanza extensions, if the returned set is not the empty set.
     * </p>
     *
     * @param elementName the element name, must not be None.
     * @param namespace the namespace of the element(s), must not be None.
     * @return a set of all matching extensions.
     */
    public func getExtensions(elementName: String, namespace: String): ArrayList<ExtensionElement> {
        StringUtils.requireNotNullNorEmpty(elementName, "elementName must not be None nor empty")
        StringUtils.requireNotNullNorEmpty(namespace, "namespace must not be None nor empty")
        let key = QName(namespace, elementName)
        return getExtensions(key)
    }

    public override func getExtensions(qname: QName): ArrayList<ExtensionElement> {
        let res: ArrayList<ExtensionElement>
        synchronized(extensionElements.lock) {
            res = extensionElements.getAll(qname)
        }
        return res // TODO Collections.unmodifiableList(res)
    }

    public func getExtensionsByType(extensionElementClass: ClassId): ArrayList<ExtensionElement> {
        synchronized(extensionElements.lock) {
            return XmppElementUtil.getElementsFrom(extensionElements, extensionElementClass)
        }
    }

    /**
     * Returns the first extension of this stanza that has the given namespace.
     * <p>
     * When possible, use {@link #getExtensionElement(String, String)} instead.
     * </p>
     *
     * @param namespace the namespace of the extension that is desired.
     * @return the stanza extension with the given namespace.
     */
    public func getExtension(namespace: String): ?ExtensionElement {
        return PacketUtil.extensionElementFrom(getExtensions(), None, namespace)
    }

    /**
     * Returns the first extension that matches the specified element name and
     * namespace, or <code>None</code> if it doesn't exist. Extensions are
     * are arbitrary XML elements in standard XMPP stanzas.
     * <p>
     * Note that it is recommended to use {@link #getExtension(Class)} instead of this method.
     * The {@link #getExtension(Class)} is more robust, as it is type safe.
     * </p>
     *
     * @param elementName the XML element name of the extension.
     * @param namespace the XML element namespace of the extension.
     * @return the extension, or <code>None</code> if it doesn't exist.
     */
    public func getExtensionElement(elementName: String, namespace: ?String): ?ExtensionElement {
        let ns = if (let Some(ns) <- namespace) {
            ns
        } else {
            return None
        }
        let key = QName(ns, elementName)
        let packetExtension = getExtension(key)
        return packetExtension
    }

    public override func getExtension(qname: QName): ?ExtensionElement {
        synchronized(extensionElements.lock) {
            return extensionElements.getFirst(qname)
        }
    }

    /**
     * Adds a stanza extension to the packet. Does nothing if extension is None.
     * <p>
     * Please note that although this method is not yet marked as deprecated, it is recommended to use
     * {@link StanzaBuilder#addExtension(ExtensionElement)} instead.
     * </p>
     *
     * @param extension a stanza extension.
     */
    public func addExtension(extension: ?ExtensionElement): Unit {
        let ext = if (let Some(v) <- extension) {
            v
        } else {
            return
        }
        let key = ext.getQName()
        synchronized(extensionElements.lock) {
            extensionElements.put(key, ext)
        }
    }

    /**
     * Add the given extension and override eventually existing extensions with the same name and
     * namespace.
     * <p>
     * Please note that although this method is not yet marked as deprecated, it is recommended to use
     * {@link StanzaBuilder#overrideExtension(ExtensionElement)} instead.
     * </p>
     *
     * @param extension the extension element to add.
     * @return one of the removed extensions or <code>None</code> if there are none.
     */
    public func overrideExtension(extensionElement: ?ExtensionElement): ?ExtensionElement {
        let extension = if (let Some(v) <- extensionElement) {
            v
        } else {
            return None
        }
        synchronized(extensionElements.lock) {
            let removedExtension = removeExtension(extension.getElementName(), extension.getNamespace())
            addExtension(extension)
            return removedExtension
        }
    }

    /**
     * Adds a collection of stanza extensions to the packet. Does nothing if extensions is None.
     *
     * @param extensions a collection of stanza extensions
     */
    public func addExtensions(extensions: Collection<ExtensionElement>): Unit {
        for (packetExtension in extensions) {
            addExtension(packetExtension)
        }
    }

    /**
     * Check if a stanza extension with the given element and namespace exists.
     * <p>
     * The argument <code>elementName</code> may be None.
     * </p>
     *
     * @param elementName
     * @param namespace
     * @return true if a stanza extension exists, false otherwise.
     */
    public func hasExtension(elementNameStr: ?String, namespace: String): Bool {
        let elementName = if (let Some(v) <- elementNameStr) {
            v
        } else {
            return hasExtension(namespace)
        }
        let key = QName(namespace, elementName)
        synchronized(extensionElements.lock) {
            return extensionElements.containsKey(key)
        }
    }

    // Overridden in order to avoid an extra copy.
    public override func hasExtension(namespace: String): Bool {
        synchronized(extensionElements.lock) {
            for (packetExtension in extensionElements.values()) {
                if (packetExtension.getNamespace() == namespace) {
                    return true
                }
            }
        }
        return false
    }

    /**
     * Remove the stanza extension with the given elementName and namespace.
     *
     * @param elementName
     * @param namespace
     * @return the removed stanza extension or None.
     */
    public func removeExtension(elementName: String, namespace: String): ?ExtensionElement {
        let key = QName(namespace, elementName)
        synchronized(extensionElements.lock) {
            return extensionElements.remove(key)
        }
    }

    public override func getNamespace(): String {
        return namespace
    }

    /**
     * Returns the default language used for all messages containing localized content.
     *
     * @return the default language
     */
    public static func getDefaultLanguage(): String {
        return DEFAULT_LANGUAGE
    }

    /**
     * Add to, from, and id attributes.
     *
     * @param xml the {@link XmlStringBuilder}.
     */
    protected func addCommonAttributes(xml: XmlStringBuilder): Unit {
        xml.optAttribute("to", getTo()?.toString())
        xml.optAttribute("from", getFrom()?.toString())
        xml.optAttribute("id", getStanzaId())
    }

    protected open func logCommonAttributes(sb: StringBuilder): Unit {
        if (let Some(to) <- getTo()) {
            sb.append("to=${to},")
        }
        if (let Some(froms) <- getFrom()) {
            sb.append("from=${froms},")
        }
        if (hasStanzaIdSet()) {
            sb.append("id=${id??"null"},")
        }
    }

    /**
     * Append an XMPPError is this stanza has one set.
     *
     * @param xml the XmlStringBuilder to append the error to.
     */
    protected func appendErrorIfExists(xml: XmlStringBuilder): Unit {
        let error = getError()
        if (let Some(e: Element) <- error) {
            xml.append(e)
        }
    }

    /**
     * Return the provided non-empty language, or use this {@link XmlLangElement} language (if set).
     *
     * @param language the provided language, may be the empty string or <code>None</code>.
     * @return the provided language or this element's language (if set).
     */
    static func determineLanguage(xmlLangElement: XmlLangElement, language: ?String): ?String {
        if (language.isSome() && !language.getOrThrow().isEmpty()) {
            return language
        }
        return xmlLangElement.getLanguage()
    }
}
