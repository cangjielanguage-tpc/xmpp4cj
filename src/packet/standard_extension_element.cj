/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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

    /**
     * 构造方法
     *
     * @param name 扩展元素的名称。
     * @param namespace 扩展元素的命名空间。
     * @param attributes 属性列表。
     * @param text 文本。
     * @param elements 节点列表。
     */
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

    /**
     * 通过属性名获取属性值。
     *
     * @param attribute 属性名。
     * @return 属性值。
     */
    public open func getAttributeValue(attribute: String): ?String {
        return attributes.get(attribute)
    }

    /**
     * 获取所有属性Map列表。
     *
     * @return 属性Map列表。
     */
    public open func getAttributes(): Map<String, String> {
        return Collections.unmodifiableMap(attributes)
    }

    /**
     * 通过元素名和命名空间获取第一条元素。
     *
     * @param element 元素名。
     * @param namespace 命名空间。
     * @return 第一条元素。
     */
    public open func getFirstElement(element: String, namespace: String): ?StandardExtensionElement {
        if (elements.isNone()) {
            return None
        }
        let key = QName(namespace, element)
        return elements?.getFirst(key) ?? None
    }

    /**
     * 通过元素名获取第一条元素。
     *
     * @param element 元素名。
     * @return 第一条元素。
     */
    public open func getFirstElement(element: String): ?StandardExtensionElement {
        return getFirstElement(element, namespace)
    }

    /**
     * 通过元素名和命名空间获取所有符合的元素列表。
     *
     * @param element 元素名。
     * @param namespace 命名空间。
     * @return 元素列表。
     */
    public open func getElements(element: String, namespace: String): ?ArrayList<StandardExtensionElement> {
        if (elements.isNone()) {
            return None
        }
        let key = QName(namespace, element)
        return elements?.getAll(key) ?? None
    }

    /**
     * 通过元素名获取所有符合的元素列表。
     *
     * @param element 元素名。
     * @return 元素列表。
     */
    public open func getElements(element: String): ?ArrayList<StandardExtensionElement> {
        return getElements(element, namespace)
    }

    /**
     * 获取所有元素列表。
     *
     * @return 元素列表。
     */
    public open func getElements(): Collection<StandardExtensionElement> {
        return elements?.values() ?? EMPTY_STANDARD_EXTENSION_ELEMENT_COLLECTION
    }

    /**
     * 获取所有元素内容。
     *
     * @return 元素内容。
     */
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

    /**
     * 通过名称和命名空间生成StandardExtensionElementBuilder对象。
     *
     * @param name 扩展元素的名称。
     * @param namespace 扩展元素的命名空间。
     * @return StandardExtensionElementBuilder对象。
     */
    public static func builder(name: String, namespace: String): StandardExtensionElementBuilder {
        return StandardExtensionElementBuilder(name, namespace)
    }
}

public open class StandardExtensionElementBuilder {
    private let name: String // 正在构建的元素的名称。

    private let namespace: String // The namespace of the element being built  

    private var attributes: ?Map<String, String> = None // 正在构建的元素的命名空间。 

    private var text: ?String = None // 元素的文本内容。 

    private var elements: ?MultiMap<QName, StandardExtensionElement> = None // 子元素。

    /**
     * 使用指定的名称和命名空间构造新的Builder实例。
     *
     * @param name 要构建的元素的名称
     * @param namespace 要构建的元素的命名空间
     */
    init(name: String, namespace: String) {
        this.name = name
        this.namespace = namespace
    }

    /**
     * 为正在构建的元素添加属性。
     *
     * @param name 属性的名称（不能为null或空）
     * @param value 属性的值（不能为null）
     * @return 方法链的当前Builder实例
     * @throws NullPointerException  如果属性名或值为null，抛出NullPointerException
     * @throws IllegalArgumentException  如果属性名为空，抛出IllegalArgumentException
     */
    public open func addAttribute(name: String, value: String): StandardExtensionElementBuilder {
        if (attributes.isNone()) {
            attributes = HashMap<String, String>()
        }
        attributes?.add(name, value)
        return this
    }

    /**
     * 为正在构建的元素添加多个属性。
     *
     * @param attributes 要添加的属性映射（可以为空，但不能为null）
     * @return 方法链的当前Builder实例
     */
    public open func addAttributes(attributes: Map<String, String>): StandardExtensionElementBuilder {
        if (this.attributes.isNone()) {
            this.attributes = HashMap<String, String>(attributes.size)
        }
        this.attributes?.add(all: attributes)
        return this
    }

    /**
     * 设置正在构建的元素的文本内容。
     *
     * @param text 文本内容（不能为空）
     * @return 方法链的当前Builder实例
     * @throws NullPointerException 如果文本为null，抛出NullPointerException
     */
    public open func setText(text: String): StandardExtensionElementBuilder {
        this.text = text
        return this
    }

    /**
     * 将子元素添加到正在构建的元素中。
     *
     * @param element 要添加的子元素（不能为null）
     * @return 方法链的当前Builder实例
     * @throws NullPointerException 如果元素为null
     */
    public open func addElement(element: StandardExtensionElement): StandardExtensionElementBuilder {
        if (elements.isNone()) {
            elements = MultiMap<QName, StandardExtensionElement>()
        }
        let key = element.getQName()
        elements?.put(key, element)
        return this
    }

    /**
     * 将具有指定名称和文本内容的子元素添加到正在构建的元素中。
     *
     * @param name 子元素的名称。
     * @param textValue 子元素的文本内容。
     * @return 方法链的当前Builder实例。
     */
    public open func addElement(name: String, textValue: String): StandardExtensionElementBuilder {
        let element = StandardExtensionElement.builder(name, this.namespace).setText(textValue).build()
        return addElement(element)
    }

    /**
     * 根据生成器的当前配置构建并返回{@link StandardExtensionElement}的新实例。
     *
     * @return 一个新的StandardExtensionElement实例。
     */
    public open func build(): StandardExtensionElement {
        return StandardExtensionElement(name, namespace, attributes, text, elements)
    }
}

extend StandardExtensionElement <: Equatable<StandardExtensionElement> {
    public operator func ==(rhs: StandardExtensionElement): Bool {
        return refEq(this, rhs)
    }
}
