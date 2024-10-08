/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * XmlStringBuilder 类用于构建 XML 字符串。
 * 它实现了 Appendable、CharSequence 和 Element 接口，提供了一系列方法来构建和操作 XML 元素。
 */
public open class XmlStringBuilder <: Appendable & CharSequence & Element {
    /**
     * 右尖括号字符
     */
    public static let RIGHT_ANGLE_BRACKET = '>'

    private let sb: LazyStringBuilder // 存储构建的 XML 字符串

    private let effectiveXmlEnvironment: ?XmlEnvironment // 有效的 XML 环境

    /**
     * 默认构造函数，初始化 XmlStringBuilder。
     */
    public init() {
        sb = LazyStringBuilder()
        effectiveXmlEnvironment = None
    }

    /**
     * 根据给定的扩展元素初始化 XmlStringBuilder。
     *
     * @param pe 扩展元素
     */
    public init(pe: ExtensionElement) {
        this(pe, None)
    }

    /**
     * 根据给定的命名元素初始化 XmlStringBuilder。
     *
     * @param e 命名元素
     */
    public init(e: NamedElement) {
        this()
        sb.append('<').append(e.getElementName()) // halfOpenElement(e.getElementName())
    }

    /**
     * 根据给定的完全限定元素和 XML 环境初始化 XmlStringBuilder。
     *
     * @param element 完全限定元素
     * @param enclosingXmlEnvironment 包含的 XML 环境
     */
    public init(element: FullyQualifiedElement, enclosingXmlEnvironment: ?XmlEnvironment) {
        this(element.getElementName(), element.getNamespace(), element.getLanguage(), enclosingXmlEnvironment)
    }

    /**
     * 根据元素名称、XML 命名空间、语言以及外部 XML 环境初始化 XmlStringBuilder。
     *
     * @param elementName 元素名称
     * param xmlNs XML 命名空间
     * @param xmlLang XML 语言
     * @param enclosingXmlEnvironment 包含的 XML 环境
     */
    public init(elementName: String, xmlNs: String, xmlLang: ?String, enclosingXmlEnvironment: ?XmlEnvironment) {
        sb = LazyStringBuilder()
        sb.append('<').append(elementName) // halfOpenElement(elementName)

        if ((enclosingXmlEnvironment?.effectiveNamespaceEquals(xmlNs) ?? false) == false) {
            if (!xmlNs.isEmpty()) {
                sb.append(XmlNsAttribute(xmlNs))
            }
        }
        if ((enclosingXmlEnvironment?.effectiveLanguageEquals(xmlLang) ?? false) == false) {
            if (let Some(lang) <- xmlLang) {
                sb.append(' ').append("xml:lang").append("='")
                sb.append(StringUtils.escapeForXmlAttributeApos(lang))
                sb.append('\'')
            }
        }

        effectiveXmlEnvironment = XmlEnvironment.builder().withNamespace(xmlNs).withLanguage(xmlLang).withNext(
            enclosingXmlEnvironment).build()
    }

    /**
     * 获取有效的 XML 环境。
     *
     * @return 有效的 XML 环境
     */
    public func getXmlEnvironment(): ?XmlEnvironment {
        return effectiveXmlEnvironment
    }

    /**
     * 添加一个新的元素，内容为转义后的字符串。
     *
     * @param name 元素名称
     * @param escapedContent 转义后的内容
     * @return 当前 XmlStringBuilder 实例
     */
    public func escapedElement(name: String, escapedContent: String): XmlStringBuilder {
        openElement(name)
        append(escapedContent)
        closeElement(name)
        return this
    }

    /**
     * 向此构建器添加一个新元素。
     *
     * @param name 元素名称
     * @param content 元素内容
     * @return XmlStringBuilder
     */
    public func element(name: String, content: String): XmlStringBuilder {
        if (content.size == 0) {
            return emptyElement(name)
        }
        openElement(name)
        escape(content)
        closeElement(name)
        return this
    }

    /**
     * 向此构建器添加一个新元素，将 {@link DateTime} 实例作为其内容，该内容将使用 {@link XmppDateTime#formatXEP0082Date(DateTime)} 进行格式化。
     *
     * @param name 元素名称
     * @param content 元素内容
     * @return 此 XmlStringBuilder
     */
    public func element(name: String, content: DateTime): XmlStringBuilder {
        return element(name, XmppDateTime.formatXEP0082Date(content))
    }

    /**
     * 向此构建器添加一个新元素。
     *
     * @param name 元素名称
     * @param content 元素内容
     * @return XmlStringBuilder
     */
    public func element(name: String, content: ToString): XmlStringBuilder {
        element(name, content.toString())
        return this
    }

    /**
     * 向此构建器添加一个新元素。
     *
     * @param name 元素名称。
     * @param content 元素内容。
     * @return 此 XmlStringBuilder。
     */
    public func optElement(name: String, content: ?String): XmlStringBuilder {
        if (let Some(content) <- content) {
            element(name, content)
        }
        return this
    }

    /**
     * 向此构建器添加一个新元素，将 {@link DateTime} 实例作为其内容，如果 {@link DateTime} 实例不是<code>None</code>，则使用 {@link XmppDateTime#formatXEP0082Date(DateTime)} 进行格式化。
     *
     * @param name 元素名称。
     * @param content 元素内容。
     * @return 此 XmlStringBuilder。
     */
    public func optElement(name: String, content: ?DateTime): XmlStringBuilder {
        if (let Some(content) <- content) {
            element(name, content)
        }
        return this
    }

    /**
     * 向此构建器添加一个新元素。
     *
     * @param name 元素名称。
     * @param content 元素内容。
     * @return 此 XmlStringBuilder。
     */
    public func optElement(name: String, content: ?ToString): XmlStringBuilder {
        if (let Some(content) <- content) {
            element(name, content.toString())
        }
        return this
    }

    /**
     * 向此构建器添加一个新元素。
     *
     * @param element Element节点。
     * @return 此 XmlStringBuilder。
     */
    public func optElement(element: ?Element): XmlStringBuilder {
        if (let Some(element) <- element) {
            append(element)
        }
        return this
    }

    /**
     * 可选地添加一个整型元素。如果值大于等于0，则添加该元素。
     *
     * @param name 元素名称
     * @param value 整型值
     * @return 当前 XmlStringBuilder 实例
     */
    public func optIntElement(name: String, value: Int): XmlStringBuilder {
        if (value >= 0) {
            element(name, value.toString())
        }
        return this
    }

    /**
     * 开始一个半开放的 XML 元素。
     *
     * @param name 元素名称
     * @return 当前 XmlStringBuilder 实例
     */
    public func halfOpenElement(name: String): XmlStringBuilder {
        sb.append('<').append(name)
        return this
    }

    /**
     * 根据 NamedElement 开始一个半开放的 XML 元素。
     *
     * @param namedElement NamedElement 对象
     * @return 当前 XmlStringBuilder 实例
     */
    public func halfOpenElement(namedElement: NamedElement): XmlStringBuilder {
        return halfOpenElement(namedElement.getElementName())
    }

    /**
     * 开始一个开放的 XML 元素。
     *
     * @param name 元素名称
     * @return 当前 XmlStringBuilder 实例
     */
    public func openElement(name: String): XmlStringBuilder {
        halfOpenElement(name).rightAngleBracket()
        return this
    }
    /**
     * 关闭一个 XML 元素。
     *
     * @param name 元素名称
     * @return 当前 XmlStringBuilder 实例
     */
    public func closeElement(name: String): XmlStringBuilder {
        sb.append("</").append(name)
        rightAngleBracket()
        return this
    }

    /**
     * 根据 NamedElement 关闭一个 XML 元素。
     *
     * @param e NamedElement 对象
     * @return 当前 XmlStringBuilder 实例
     */
    public func closeElement(e: NamedElement): XmlStringBuilder {
        closeElement(e.getElementName())
        return this
    }

    /**
     * 关闭一个空元素。
     *
     * @return 当前 XmlStringBuilder 实例
     */
    public func closeEmptyElement(): XmlStringBuilder {
        sb.append("/>")
        return this
    }

    /**
     * 添加一个右尖括号“>”。
     *
     * @return 对此对象的引用。
     */
    public func rightAngleBracket(): XmlStringBuilder {
        sb.append(RIGHT_ANGLE_BRACKET)
        return this
    }

    /**
     * 如果值是<code>None</code>，则什么也不做。
     *
     * @param name 属性名称
     * @param value 属性值
     * @return XmlStringBuilder
     */
    public func attribute(name: String, value: String): XmlStringBuilder {
        sb.append(' ').append(name).append("=\'")
        escapeAttributeValue(value)
        sb.append('\'')
        return this
    }

    /**
     * 添加一个布尔属性。
     *
     * @param name 属性名称
     * @param bool 布尔值
     * @return 当前 XmlStringBuilder 实例
     */
    public func attribute(name: String, bool: Bool): XmlStringBuilder {
        return attribute(name, bool)
    }

    /**
     * 向此构建器添加一个新属性，将 {@link DateTime} 实例作为其值，该值将使用 {@link XmppDateTime#formatXEP0082Date(DateTime)} 进行格式化。
     *
     * @param name 属性名称
     * @param value 属性值
     * @return 此 XmlStringBuilder
     */
    public func attribute(name: String, value: DateTime): XmlStringBuilder {
        return attribute(name, XmppDateTime.formatXEP0082Date(value))
    }

    /**
     * 添加一个字符序列属性。
     *
     * @param name 属性名称
     * @param value 属性值
     * @return 当前 XmlStringBuilder 实例
     */
    public func attribute(name: String, value: ToString): XmlStringBuilder {
        return attribute(name, value.toString())
    }

    /**
     * 添加一个Int64属性。
     *
     * @param name 属性名称
     * @param value 整型值
     * @return 当前 XmlStringBuilder 实例
     */
    public func attribute(name: String, value: Int): XmlStringBuilder {
        return attribute(name, value.toString())
    }

    /**
     * 可选地添加一个属性，如果值不为 null。
     *
     * @param name 属性名称
     * @param value 属性值
     * @return 当前 XmlStringBuilder 实例
     */
    public func optAttribute(name: String, value: ?String): XmlStringBuilder {
        if (let Some(value) <- value) {
            attribute(name, value)
        }
        return this
    }

    /**
     * 可选地添加一个Int64属性，如果值不为 null。
     *
     * @param name 属性名称
     * @param value 长整型值
     * @return 当前 XmlStringBuilder 实例
     */
    public func optAttribute(name: String, value: ?Int64): XmlStringBuilder {
        if (let Some(value) <- value) {
            attribute(name, value)
        }
        return this
    }

    /**
     * 向此构建器添加一个新属性，将 {@link DateTime} 实例作为其值，如果 {@link DateTime} 实例不是<code>None</code>，则使用 {@link XmppDateTime#formatXEP0082Date(DateTime)} 进行格式化。
     *
     * @param name 属性名称
     * @param value 属性值
     * @return 此 XmlStringBuilder
     */
    public func optAttribute(name: String, value: ?DateTime): XmlStringBuilder {
        if (let Some(value) <- value) {
            attribute(name, value)
        }
        return this
    }

    // public func optAttribute(name: String, value: ?ToString): XmlStringBuilder {
    //     if (let Some(value) <- value) {
    //         attribute(name, value.toString())
    //     }
    //     return this
    // }

    /**
     * 与 {@link #optAttribute(String, CharSequence)} 相同，但方法名称不同。如果提供的属性值参数类型在方法重载中引起歧义，可以使用此方法。例如，如果类型是 Number 和 CharSequence 的子类。
     *
     * @param name 属性名称。
     * @param value 属性值。
     * @return 对此对象的引用。
     */
    public func optAttributeCs(name: String, value: ?ToString): XmlStringBuilder {
        return optAttribute(name, value?.toString())
    }

    /**
     * 如果值<code>=> 0</code>，则添加给定属性。
     *
     * @param name 属性名称。
     * @param value 属性值。
     * @return 对此对象的引用。
     */
    public func optIntAttribute(name: String, value: Int): XmlStringBuilder {
        if (value >= 0) {
            attribute(name, value.toString())
        }
        return this
    }

    /**
     * 如果提供的整数参数不是<code>None</code>，则使用给定名称和整数作为值添加一个新的 XML 属性。
     *
     * @param name XML 属性名称。
     * @param value 用作属性值的可选整数。
     * @return 对此对象的引用。
     */
    public func optIntAttribute(name: String, value: ?Int): XmlStringBuilder {
        if (let Some(value) <- value) {
            if (value > 0) {
                attribute(name, value.toString())
            }
        }
        return this
    }

    /**
     * 可选地添加一个布尔属性，如果布尔值为 true。
     *
     * @param name 属性名称
     * @param bool 布尔值
     * @return 当前 XmlStringBuilder 实例
     */
    public func optBooleanAttribute(name: String, bool: Bool): XmlStringBuilder {
        if (bool) {
            sb.append(' ').append(name).append("='true'")
        }
        return this
    }

    /**
     * 可选地添加一个布尔属性，如果布尔值为 false。
     *
     * @param name 属性名称
     * @param bool 布尔值
     * @return 当前 XmlStringBuilder 实例
     */
    public func optBooleanAttributeDefaultTrue(name: String, bool: Bool): XmlStringBuilder {
        if (!bool) {
            sb.append(' ').append(name).append("='false'")
        }
        return this
    }

    /**
     * 添加 XML 命名空间属性。
     *
     * @param value 命名空间值
     * @return 当前 XmlStringBuilder 实例
     */
    public func xmlnsAttribute(value: ?String): XmlStringBuilder {
        let v = if (let Some(v) <- value) {
            v
        } else {
            return this
        }
        if (effectiveXmlEnvironment?.effectiveNamespaceEquals(v) ?? false) {
            return this
        }
        let xmlNsAttribute = XmlNsAttribute(v)
        append(xmlNsAttribute)
        return this
    }

    /**
     * 添加 xml:lang 属性。
     *
     * @param value 语言值
     * @return 当前 XmlStringBuilder 实例
     */
    public func xmllangAttribute(value: ?String): XmlStringBuilder {
        optAttribute("xml:lang", value)
        return this
    }

    /**
     * 可选地添加 xml:lang 属性，如果语言不为空。
     *
     * @param lang 语言值
     * @return 当前 XmlStringBuilder 实例
     */
    public func optXmlLangAttribute(lang: ?String): XmlStringBuilder {
        if (!StringUtils.isNullOrEmpty(lang)) {
            xmllangAttribute(lang.getOrThrow())
        }
        return this
    }

    /**
     * 添加文本内容，自动转义。
     *
     * @param text 文本内容
     * @return 当前 XmlStringBuilder 实例
     */
    public func text(text: ToString): XmlStringBuilder {
        let escapedText = StringUtils.escapeForXmlText(text.toString())
        sb.append(escapedText)
        return this
    }

    /**
     * 转义文本内容，用于 XML。
     *
     * @param text 原始文本
     * @return 当前 XmlStringBuilder 实例
     */
    public func escape(text: String): XmlStringBuilder {
        sb.append(StringUtils.escapeForXml(text))
        return this
    }

    /**
     * 转义属性值，用于 XML 属性。
     *
     * @param value 属性值
     * @return 当前 XmlStringBuilder 实例
     */
    public func escapeAttributeValue(value: String): XmlStringBuilder {
        sb.append(StringUtils.escapeForXmlAttributeApos(value))
        return this
    }

    /**
     * 可选地转义文本内容，如果文本不为 null。
     *
     * @param text 原始文本
     * @return 当前 XmlStringBuilder 实例
     */
    public func optEscape(text: ?ToString): XmlStringBuilder {
        if (let Some(text) <- text) {
            return escape(text.toString())
        }
        return this
    }

    /**
     * 转义字符序列文本。
     *
     * @param text 字符序列
     * @return 当前 XmlStringBuilder 实例
     */
    public func escape(text: ToString): XmlStringBuilder {
        return escape(text.toString())
    }

    /**
     * 添加一个前导元素。
     *
     * @param pe 完全限定的元素
     * @return 当前 XmlStringBuilder 实例
     */
    protected func prelude(pe: FullyQualifiedElement): XmlStringBuilder {
        return prelude(pe.getElementName(), pe.getNamespace())
    }

    /**
     * 添加一个前导元素，包含命名空间。
     *
     * @param elementName 元素名称
     * @param namespace 命名空间
     * @return 当前 XmlStringBuilder 实例
     */
    protected func prelude(elementName: String, namespace: String): XmlStringBuilder {
        halfOpenElement(elementName)
        xmlnsAttribute(namespace)
        return this
    }

    /**
     * 可选地添加元素，如果元素不为 null。
     *
     * @param element 元素
     * @return 当前 XmlStringBuilder 实例
     */
    public func optAppend(element: ?Element): XmlStringBuilder {
        if (let Some(element) <- element) {
            append(element.toXML(effectiveXmlEnvironment))
        }
        return this
    }

    /**
     * 可选地添加元素集合，如果集合不为 null。
     *
     * @param elements 元素集合
     * @return 当前 XmlStringBuilder 实例
     */
    public func optAppend<E>(elements: ?Collection<E>): XmlStringBuilder where E <: Element {
        if (let Some(elements) <- elements) {
            append(elements)
        }
        return this
    }

    /**
     * 可选地添加文本子元素，如果文本不为 null。
     *
     * @param sqc 文本内容
     * @param parentElement 父元素
     * @return 当前 XmlStringBuilder 实例
     */
    public func optTextChild(sqc: ?ToString, parentElement: NamedElement): XmlStringBuilder {
        if (let Some(sqc) <- sqc) {
            rightAngleBracket()
            escape(sqc)
            closeElement(parentElement)
            return this
        } else {
            return closeEmptyElement()
        }
    }

    /**
     * 添加另一个 XmlStringBuilder 的内容。
     *
     * @param xsb 另一个 XmlStringBuilder
     * @return 当前 XmlStringBuilder 实例
     */
    public func append(xsb: XmlStringBuilder): XmlStringBuilder {
        sb.append(xsb.sb)
        return this
    }

    /**
     * 添加元素的 XML 表示。
     *
     * @param element 元素
     * @return 当前 XmlStringBuilder 实例
     */
    public func append(element: Element): XmlStringBuilder {
        append(element.toXML(effectiveXmlEnvironment))
        return this
    }

    /**
     * 添加元素集合的 XML 表示。
     *
     * @param elements 元素集合
     * @return 当前 XmlStringBuilder 实例
     */
    public func append<E>(elements: Collection<E>): XmlStringBuilder where E <: Element {
        for (element in elements) {
            append(element)
        }
        return this
    }

    /**
     * 添加一个空元素，使用 toString() 方法。
     *
     * @param element 枚举类型元素
     * @return 当前 XmlStringBuilder 实例
     */
    public func emptyElement(element: ToString): XmlStringBuilder {
        return emptyElement(element.toString())
    }

    /**
     * 添加一个空元素。
     *
     * @param element 元素名称
     * @return 当前 XmlStringBuilder 实例
     */
    public func emptyElement(element: String): XmlStringBuilder {
        halfOpenElement(element)
        return closeEmptyElement()
    }

    /**
     * 根据条件添加一个空元素。
     *
     * @param condition 条件
     * @param element 元素名称
     * @return 当前 XmlStringBuilder 实例
     */
    public func condEmptyElement(condition: Bool, element: ?String): XmlStringBuilder {
        if (condition) {
            emptyElement(element)
        }
        return this
    }

    /**
     * 根据条件添加属性。
     *
     * @param condition 条件
     * @param name 属性名称
     * @param value 属性值
     * @return 当前 XmlStringBuilder 实例
     */
    public func condAttribute(condition: Bool, name: String, value: ?String): XmlStringBuilder {
        if (condition) {
            attribute(name, value)
        }
        return this
    }

    /**
     * 将指定的字符序列附加到此｛@code Appendable｝。
     *
     * @param csq 要附加的字符序列。
     * @return 返回Appendable对象。
     */
    public override func append(csq: CharSequence): Appendable {
        sb.append(csq)
        return this
    }

    // override public  func append(csq: String, start: Int, end: Int): XmlStringBuilder {
    //     sb.append(csq, start, end)
    //     return this
    // }

    // override public  func append(c: Rune): XmlStringBuilder {
    //     sb.append(c)
    //     return this
    // }

    // override public  func charAt(index: Int): Char {
    //     return sb.charAt(index)
    // }

    // override public  func subSequence(start: Int, end: Int): ?String {
    //     return sb.subSequence(start, end)
    // }

    // override public  func equals(other: ?Object): Bool {
    //     if (!(ValueBox<String>.check(other))) {
    //         return false
    //     }
    //     let otherCharSequenceBuilder = ValueBox<String>.cast(other)
    //     return <-- No type transform for: toString().<-- Мapping is present but failed: equals -->(toString(otherCharSequenceBuilder)) : Any -> Bool -->
    // }

    // override public  func hashCode(): Int64 {
    //     return toString().hashCode()
    // }

    /**
     * 文本长度。
     */
    public prop size: Int {
        get() {
            sb.size
        }
    }

    public override func toString(): String {
        return sb.toString()
    }

    /**
     * 将此<code>XmlStringBuilder</code>的内容写入｛@link Writer｝。这将逐一写入单个部分，避免分配一个大的连续内存块来保存。
     *
     * @param writer 写入数据流
     * @param enclosingXmlEnvironment 封闭的XML环境。
     * @throws IOException  如果发生I/O错误，会抛出IOException。
     */
    public func write(writer: StringWriter<OutputStream>, enclosingXmlEnvironment: XmlEnvironment): Unit {
        try {
            appendXmlTo(
                {
                    csq => try {
                        writer.write(csq)
                    } catch (e: IOException) {
                        throw WrappedIoException(e)
                    }
                },
                enclosingXmlEnvironment
            )
        } catch (e: WrappedIoException) {
            throw e.wrappedIoException
        }
    }

    /**
     * 将 XML 内容转换为列表。
     *
     * @param enclosingXmlEnvironment 包含的 XML 环境
     * @return XML 内容的列表
     */
    public func toList(enclosingXmlEnvironment: XmlEnvironment): ArrayList<ToString> {
        let res = ArrayList<ToString>(sb.getAsList().size)
        appendXmlTo({csq => res.append(csq)}, enclosingXmlEnvironment)
        return res
    }

    public override func toXML(enclosingXmlEnvironment: ?XmlEnvironment): StringBuilder {
        // This is only the potential length, since the actual length depends on the given XmlEnvironment.
        let potentialLength = size
        let res = StringBuilder(potentialLength)
        appendXmlTo({csq => res.append(csq)}, enclosingXmlEnvironment)
        return res
    }

    private func appendXmlTo(charSequenceSink: (ToString) -> Unit, enclosingXmlEnvironment: ?XmlEnvironment): Unit {
        var xmlEnv = enclosingXmlEnvironment
        for (csq in sb.getAsList()) {
            match (csq) {
                case cs: XmlStringBuilder => cs.appendXmlTo(charSequenceSink, xmlEnv)
                case xmlNsAttribute: XmlNsAttribute where xmlEnv?.getEffectiveNamespace() != xmlNsAttribute.value =>
                    charSequenceSink(xmlNsAttribute)
                    xmlEnv = XmlEnvironment(xmlNsAttribute.value)
                case _ => charSequenceSink(csq)
            }
        }
    }
}

class XmlNsAttribute <: ToString {
    let value: String

    private let xmlFragment: String

    init(value: String) {
        this.value = value
        this.xmlFragment = " xmlns='${value}'"
    }

    public override func toString(): String {
        return xmlFragment
    }

    // override public prop size: Int {
    //     get(){xmlFragment.size}
    // }
}

class WrappedIoException <: Exception {
    let wrappedIoException: IOException

    init(wrappedIoException: IOException) {
        this.wrappedIoException = wrappedIoException
    }

    protected override func getClassName(): String {
        "WrappedIoException"
    }
}
