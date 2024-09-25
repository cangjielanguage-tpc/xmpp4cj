/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * 一个 {@link ExtensionElement}，对使用 XMPP 时经常需要和使用的 XML 特性进行建模。
 * 因此，它适用于大多数用例。
 * 使用 {@link StandardExtensionElement#builder(String, String)} 来构建这些元素。
 * <p>
 * 请注意，这仅在没有注册特定的扩展元素提供程序时作为万能方案。
 * 协议实现应该更倾向于为其用例定制自己的扩展元素模型。
 * </p>
 */
public open class StandardExtensionElement <: ExtensionElement {
    private let name: String

    private let namespace: String

    private let attributes: Map<String, String>

    private let text: ?String

    private let elements: ?MultiMap<QName, StandardExtensionElement>

    private var xmlCache: ?XmlStringBuilder = None

    /**
     * 用给定的名称和命名空间构建一个新的扩展元素，不包含其他内容。
     * <p>
     * 这是为了构建在节中用作简单标志的扩展元素。
     * <p>
     *
     * @param name 扩展元素的名称。
     * @param namespace 扩展元素的命名空间。
     */
    public init(name: String, namespace: String) {
        this(name, namespace, None, None, None)
    }

    init(name: String, namespace: String, attributes: ?Map<String, String>, text: ?String,
        elements: ?MultiMap<QName, StandardExtensionElement>) {
        this.name = name
        this.namespace = namespace
        this.attributes = attributes ?? Collections.EMPTY_STRING_MAP
        this.text = text
        this.elements = elements
    }

    public open override func getElementName(): String {
        return name
    }

    public open override func getNamespace(): String {
        return namespace
    }

    public open func getAttributeValue(attribute: String): ?String {
        return attributes.get(attribute)
    }

    public open func getAttributes(): Map<String, String> {
        return Collections.unmodifiableMap(attributes)
    }

    public open func getFirstElement(element: String, namespace: String): ?StandardExtensionElement {
        if (elements.isNone()) {
            return None
        }
        let key = QName(namespace, element)
        return elements?.getFirst(key) ?? None
    }

    public open func getFirstElement(element: String): ?StandardExtensionElement {
        return getFirstElement(element, namespace)
    }

    public open func getElements(element: String, namespace: String): ?ArrayList<StandardExtensionElement> {
        if (elements.isNone()) {
            return None
        }
        let key = QName(namespace, element)
        return elements?.getAll(key) ?? None
    }

    public open func getElements(element: String): ?ArrayList<StandardExtensionElement> {
        return getElements(element, namespace)
    }

    public open func getElements(): Collection<StandardExtensionElement> {
        return elements?.values() ?? EMPTY_STANDARD_EXTENSION_ELEMENT_COLLECTION
    }

    public open func getText(): ?String {
        return text
    }

    public open override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        if (let Some(xmlCache) <- xmlCache) {
            return xmlCache
        }
        let xml = XmlStringBuilder(this, enclosingNamespace)
        for ((k, v) in attributes) {
            xml.attribute(k, v)
        }
        xml.rightAngleBracket()
        if (let Some(text) <- text) {
            xml.text(text)
        }
        if (let Some(elements) <- elements) {
            for (v in elements.values()) {
                xml.append(v.toXML(getNamespace()))
            }
        }
        xml.closeElement(this)
        xmlCache = xml
        return xml
    }

    public static func builder(name: String, namespace: String): StandardExtensionElementBuilder {
        return StandardExtensionElementBuilder(name, namespace)
    }
}

public open class StandardExtensionElementBuilder {
    private let name: String
    private let namespace: String
    private var attributes: ?Map<String, String> = None
    private var text: ?String = None
    private var elements: ?MultiMap<QName, StandardExtensionElement> = None

    init(name: String, namespace: String) {
        this.name = name
        this.namespace = namespace
    }

    public open func addAttribute(name: String, value: String): StandardExtensionElementBuilder {
        if (attributes.isNone()) {
            attributes = HashMap<String, String>()
        }
        attributes?.put(name, value)
        return this
    }

    public open func addAttributes(attributes: Map<String, String>): StandardExtensionElementBuilder {
        if (this.attributes.isNone()) {
            this.attributes = HashMap<String, String>(attributes.size)
        }
        this.attributes?.putAll(attributes)
        return this
    }

    public open func setText(text: String): StandardExtensionElementBuilder {
        this.text = text
        return this
    }

    public open func addElement(element: StandardExtensionElement): StandardExtensionElementBuilder {
        if (elements.isNone()) {
            elements = MultiMap<QName, StandardExtensionElement>()
        }
        let key = element.getQName()
        elements?.put(key, element)
        return this
    }

    public open func addElement(name: String, textValue: String): StandardExtensionElementBuilder {
        let element = StandardExtensionElement.builder(name, this.namespace).setText(textValue).build()
        return addElement(element)
    }

    public open func build(): StandardExtensionElement {
        return StandardExtensionElement(name, namespace, attributes, text, elements)
    }
}

extend StandardExtensionElement <: Equatable<StandardExtensionElement> {
    public operator func ==(rhs: StandardExtensionElement): Bool {
        return refEq(this, rhs)
    }
}
