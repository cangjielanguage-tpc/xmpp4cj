/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * XMPP 节的基类。
 * <p>
 * 每个节都有一个唯一的 ID（自动生成，但可以被覆盖）。IQ 节需要节 ID，对于存在和消息节则建议使用。可选地，可以设置“to”和“from”字段。
 * </p>
 * <p>
 * XMPP 节有 {@link Message}、{@link IQ} 和 {@link Presence}。因此它们都是这个类的子类。<b>如果你认为你需要子类化这个类，那么你可能做错了什么。</b>
 * </p>
 * <p>
 * 使用 {@link StanzaBuilder} 来构建节实例。这个类的所有实例修改方法都已过时，尽管目前并非所有方法都被标记为过时，但绝不能使用。
 * </p>
 * @see <a href="xmpp/org/rfcs/rfc6120.html#stanzas">RFC 6120 § 8. XML Stanzas</a>
 */
public abstract class Stanza <: StanzaView & TopLevelStreamElement & ToString {
    /**
     * text文本。
     */
    public static let TEXT = "text"

    /**
     * item文本。
     */
    public static let ITEM = "item"

    /**
     * TODO 默认语言。
     */
    protected static let DEFAULT_LANGUAGE = "en"

    /**
     * 假设所有节Xmpp句柄都在客户端命名空间中，
     * 因为Xmpp4cj是一个XMPP客户端库。
     * 如果需要，我们可以稍后更改此行为。
     */
    private let namespace = StreamOpen.CLIENT_NAMESPACE

    private let extensionElements: MultiMap<QName, ExtensionElement>

    private let usedStanzaIdSource: ?StanzaIdSource

    private var id: ?String

    private var to: ?Jid = None

    private var froms: ?Jid = None

    private var error: ?StanzaError = None

    /**
     * 节最外层元素的“xml:lang”属性的可选值。
     * <p>
     * 这样的属性对所有节类型都有定义。对于 IQ，例如参见 XEP-50 3.7：
     * “请求者应该在&lt;iq/&gt;（推荐）或&lt;command/&gt;元素上使用‘xml:lang’属性提供其区域设置信息。”
     * </p>
     */
    protected var language: ?String = None

    /**
     * 默认构造方法
     */
    protected init() {
        extensionElements = MultiMap<QName, ExtensionElement>()
        usedStanzaIdSource = None
        id = StandardStanzaIdSource.DEFAULT.getNewStanzaId()
    }

    /**
     * 通过StanzaBuilder对象构造构造Stanza
     *
     * @param stanzaBuilder StanzaBuilder对象。
     */
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

    /**
     * 通过Stanza对象构造构造Stanza
     *
     * @param p Stanza对象。
     */
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
     * 设置数据包的唯一 ID。要表示一个节没有 ID，将<code>None</code>作为数据包的 ID 值传递。
     *
     * @param id 数据包的唯一 ID。
     */
    public open func setStanzaId(id: ?String): Unit {
        if (id.isSome()) {
            StringUtils.requireNotNullNorEmpty(id, "id must either be None or not the empty String")
        }
        this.id = id
    }

    /**
     * 检查这个节是否设置了 ID。
     *
     * @return 如果节 ID 已设置则为 true，否则为 false。
     */
    public func hasStanzaIdSet(): Bool {
        return id.isSome()
    }

    /**
     * 如果这个节没有设置节 ID，则抛出 {@link IllegalArgumentException}。
     *
     * @throws IllegalArgumentException 如果这个节没有设置节 ID。
     */
    public func throwIfNoStanzaId(): Unit {
        if (hasStanzaIdSet()) {
            return
        }
        throw IllegalArgumentException("The stanza has no RFC stanza ID set, although one is required")
    }

    /**
     * 确保设置一个节 ID。
     *
     * @return 节 ID。
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
     * 设置数据包要发送给谁。XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。
     *
     * @param to 数据包要发送给谁。
     */
    public open func setTo(to: ?Jid): Unit {
        this.to = to
    }

    public override func getFrom(): ?Jid {
        return froms
    }

    /**
     * 设置数据包从谁那里发送。XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。
     *
     * @param from 数据包从谁那里发送。
     */
    public open func setFrom(froms: ?Jid): Unit {
        this.froms = froms
    }

    public override func getError(): ?StanzaError {
        return error
    }

    /**
     * 为这个节设置错误。
     *
     * @param stanzaError 这个节携带并因此表示的错误。
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

    /**
     * 获取节点列表。
     *
     * @return 获取节点列表。
     */
    public func getExtensionsMap(): MultiMap<QName, ExtensionElement> {
        return cloneExtensionsMap()
    }

    func cloneExtensionsMap(): MultiMap<QName, ExtensionElement> {
        synchronized(extensionElements.lock) {
            return extensionElements.clone()
        }
    }

    /**
     * 返回具有给定元素名称和命名空间的所有扩展的列表。
     * <p>
     * 如果返回的集合不是空集合，对返回集合的更改将更新节扩展。
     * </p>
     *
     * @param elementName 元素名称，不能为空。
     * @param namespace 元素的命名空间，不能为空。
     * @return 所有匹配扩展的集合。
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

    /**
     * 通过ClassId获取节点元素列表。
     *
     * @param extensionElementClass ClassId。
     * @return 获取节点元素列表。
     */
    public func getExtensionsByType(extensionElementClass: ClassId): ArrayList<ExtensionElement> {
        synchronized(extensionElements.lock) {
            return XmppElementUtil.getElementsFrom(extensionElements, extensionElementClass)
        }
    }

    /**
     * 返回这个节中具有给定命名空间的第一个扩展。
     * <p>
     * 在可能的情况下，使用 {@link #getExtensionElement(String, String)} 代替。
     * </p>
     *
     * @param namespace 所需扩展的命名空间。
     * @return 具有给定命名空间的节扩展。
     */
    public func getExtension(namespace: String): ?ExtensionElement {
        return PacketUtil.extensionElementFrom(getExtensions(), None, namespace)
    }

    /**
     * 返回第一个与指定元素名称和命名空间匹配的扩展，或者如果不存在则返回<code>None</code>。扩展是标准 XMPP 节中的任意 XML 元素。
     * <p>
     * 请注意，建议使用 {@link #getExtension(Class)} 代替这个方法。{@link #getExtension(Class)} 更健壮，因为它是类型安全的。
     * </p>
     *
     * @param elementName 扩展的 XML 元素名称。
     * @param namespace 扩展的 XML 元素命名空间。
     * @return 扩展，或者如果不存在则返回<code>None</code>。
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
     * 将节扩展添加到数据包中。如果扩展是<code>None</code>则什么也不做。
     * <p>
     * 请注意，尽管这个方法还没有被标记为过时，但建议使用 {@link StanzaBuilder#addExtension(ExtensionElement)} 代替。
     * </p>
     *
     * @param extension 节扩展。
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
     * 添加给定的扩展，并覆盖具有相同名称和命名空间的最终现有扩展。
     * <p>
     * 请注意，尽管这个方法还没有被标记为过时，但建议使用 {@link StanzaBuilder#overrideExtension(ExtensionElement)} 代替。
     * </p>
     *
     * @param extensionElement 要添加的扩展元素。
     * @return 被移除的扩展之一，或者如果没有则返回<code>None</code>。
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
     * 将一组节扩展添加到数据包中。如果扩展是<code>None</code>则什么也不做。
     *
     * @param extensions 一组节扩展。
     */
    public func addExtensions(extensions: Collection<ExtensionElement>): Unit {
        for (packetExtension in extensions) {
            addExtension(packetExtension)
        }
    }

    /**
     * 检查具有给定元素和命名空间的节扩展是否存在。
     * <p>
     * 参数<code>elementName</code>可以是<code>None</code>。
     * </p>
     *
     * @param elementName
     * @param namespace
     * @return 如果节扩展存在则为 true，否则为 false。
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

    /**
     * 检查具有给定命名空间的扩展元素是否存在
     * 覆盖以避免额外的副本
     *
     * @param namespace 命名空间
     * @return true表示有值，false表示None。
     */
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
     * 移除具有给定元素名称和命名空间的节扩展。
     *
     * @param elementName 名称
     * @param namespace 命名空间
     * @return 被移除的节扩展，或者如果没有则返回<code>None</code>。
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
     * 返回用于所有包含本地化内容的消息的默认语言。
     *
     * @return 默认语言。
     */
    public static func getDefaultLanguage(): String {
        return DEFAULT_LANGUAGE
    }

    /**
     * 添加“to”、“from”和“id”属性。
     *
     * @param xml {@link XmlStringBuilder}。
     */
    protected func addCommonAttributes(xml: XmlStringBuilder): Unit {
        xml.optAttribute("to", getTo()?.toString())
        xml.optAttribute("from", getFrom()?.toString())
        xml.optAttribute("id", getStanzaId())
    }

    /**
     * 对属性做String处理。
     *
     * @param sb StringBuilder
     * @param namespace 命名空间
     */
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
     * 如果这个节设置了错误，则附加一个 XMPPError。
     *
     * @param xml 要附加错误的 XmlStringBuilder。
     */
    protected func appendErrorIfExists(xml: XmlStringBuilder): Unit {
        let error = getError()
        if (let Some(e: Element) <- error) {
            xml.append(e)
        }
    }

    /**
     * 返回提供的非空语言，或者使用这个 {@link XmlLangElement} 的语言（如果设置了）。
     *
     * @param xmlLangElement XmlLangElement。
     * @param language 提供的语言，可以是空字符串或<code>None</code>。
     * @return 提供的语言或者这个元素的语言（如果设置了）。
     */
    static func determineLanguage(xmlLangElement: XmlLangElement, language: ?String): ?String {
        if (language.isSome() && !language.getOrThrow().isEmpty()) {
            return language
        }
        return xmlLangElement.getLanguage()
    }
}
