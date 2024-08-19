/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class XmlStringBuilder <: Appendable & CharSequence & Element {
    public static let RIGHT_ANGLE_BRACKET = '>'

    private let sb: LazyStringBuilder

    private let effectiveXmlEnvironment: ?XmlEnvironment

    public init() {
        sb = LazyStringBuilder()
        effectiveXmlEnvironment = None
    }

    public init(pe: ExtensionElement) {
        this(pe, None)
    }

    public init(e: NamedElement) {
        this()
        sb.append('<').append(e.getElementName()) // halfOpenElement(e.getElementName())
    }

    public init(element: FullyQualifiedElement, enclosingXmlEnvironment: ?XmlEnvironment) {
        this(element.getElementName(), element.getNamespace(), element.getLanguage(), enclosingXmlEnvironment)
    }

    public init(elementName: String, xmlNs: String, xmlLang: ?String, enclosingXmlEnvironment: ?XmlEnvironment) {
        sb = LazyStringBuilder()
        sb.append('<').append(elementName) // halfOpenElement(elementName)

        if ((enclosingXmlEnvironment?.effectiveNamespaceEquals(xmlNs) ?? false) == false) {
            sb.append(XmlNsAttribute(xmlNs))
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

    public func getXmlEnvironment(): ?XmlEnvironment {
        return effectiveXmlEnvironment
    }

    public func escapedElement(name: String, escapedContent: String): XmlStringBuilder {
        openElement(name)
        append(escapedContent)
        closeElement(name)
        return this
    }

    /**
     * Add a new element to this builder.
     *
     * @param name
     * @param content
     * @return the XmlStringBuilder
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
     * Add a new element to this builder, with the {@link DateTime} instance as its content,
     * which will get formatted with {@link XmppDateTime#formatXEP0082Date(Date)}.
     *
     * @param name element name
     * @param content content of element
     * @return this XmlStringBuilder
     */
    public func element(name: String, content: DateTime): XmlStringBuilder {
        return element(name, XmppDateTime.formatXEP0082Date(content))
    }

    /**
     * Add a new element to this builder.
     *
     * @param name
     * @param content
     * @return the XmlStringBuilder
     */
    public func element(name: String, content: ToString): XmlStringBuilder {
        element(name, content.toString())
        return this
    }

    public func optElement(name: String, content: ?String): XmlStringBuilder {
        if (let Some(content) <- content) {
            element(name, content)
        }
        return this
    }

    /**
     * Add a new element to this builder, with the {@link DateTime} instance as its content,
     * which will get formatted with {@link XmppDateTime#formatXEP0082Date(Date)}
     * if {@link DateTime} instance is not <code>None</code>.
     *
     * @param name element name
     * @param content content of element
     * @return this XmlStringBuilder
     */
    public func optElement(name: String, content: ?DateTime): XmlStringBuilder {
        if (let Some(content) <- content) {
            element(name, content)
        }
        return this
    }

    public func optElement(name: String, content: ?ToString): XmlStringBuilder {
        if (let Some(content) <- content) {
            element(name, content.toString())
        }
        return this
    }

    public func optElement(element: ?Element): XmlStringBuilder {
        if (let Some(element) <- element) {
            append(element)
        }
        return this
    }

    public func optIntElement(name: String, value: Int): XmlStringBuilder {
        if (value >= 0) {
            element(name, value.toString())
        }
        return this
    }

    public func halfOpenElement(name: String): XmlStringBuilder {
        sb.append('<').append(name)
        return this
    }

    public func halfOpenElement(namedElement: NamedElement): XmlStringBuilder {
        return halfOpenElement(namedElement.getElementName())
    }

    public func openElement(name: String): XmlStringBuilder {
        halfOpenElement(name).rightAngleBracket()
        return this
    }

    public func closeElement(name: String): XmlStringBuilder {
        sb.append("</").append(name)
        rightAngleBracket()
        return this
    }

    public func closeElement(e: NamedElement): XmlStringBuilder {
        closeElement(e.getElementName())
        return this
    }

    public func closeEmptyElement(): XmlStringBuilder {
        sb.append("/>")
        return this
    }

    /**
     * Add a right angle bracket '&gt;'.
     *
     * @return a reference to this object.
     */
    public func rightAngleBracket(): XmlStringBuilder {
        sb.append(RIGHT_ANGLE_BRACKET)
        return this
    }

    /**
     * Does nothing if value is None.
     *
     * @param name
     * @param value
     * @return the XmlStringBuilder
     */
    public func attribute(name: String, value: String): XmlStringBuilder {
        sb.append(' ').append(name).append("=\'")
        escapeAttributeValue(value)
        sb.append('\'')
        return this
    }

    public func attribute(name: String, bool: Bool): XmlStringBuilder {
        return attribute(name, bool)
    }

    /**
     * Add a new attribute to this builder, with the {@link DateTime} instance as its value,
     * which will get formatted with {@link XmppDateTime#formatXEP0082Date(Date)}.
     *
     * @param name name of attribute
     * @param value value of attribute
     * @return this XmlStringBuilder
     */
    public func attribute(name: String, value: DateTime): XmlStringBuilder {
        return attribute(name, XmppDateTime.formatXEP0082Date(value))
    }

    public func attribute(name: String, value: ToString): XmlStringBuilder {
        return attribute(name, value.toString())
    }

    public func attribute(name: String, value: Int): XmlStringBuilder {
        return attribute(name, value.toString())
    }

    public func optAttribute(name: String, value: ?String): XmlStringBuilder {
        if (let Some(value) <- value) {
            attribute(name, value)
        }
        return this
    }

    public func optAttribute(name: String, value: ?Int64): XmlStringBuilder {
        if (let Some(value) <- value) {
            attribute(name, value)
        }
        return this
    }

    /**
     * Add a new attribute to this builder, with the {@link DateTime} instance as its value,
     * which will get formatted with {@link XmppDateTime#formatXEP0082Date(Date)}
     * if {@link DateTime} instance is not <code>None</code>.
     *
     * @param name attribute name
     * @param value value of this attribute
     * @return this XmlStringBuilder
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
     * Same as {@link #optAttribute(String, CharSequence)}, but with a different method name.
     * This method can be used if the provided attribute value argument type causes ambiguity in method overloading.
     * For example if the type is a subclass of Number and CharSequence.
     *
     * @param name the name of the attribute.
     * @param value the value of the attribute.
     * @return a reference to this object.
     */
    public func optAttributeCs(name: String, value: ?ToString): XmlStringBuilder {
        return optAttribute(name, value?.toString())
    }

    /**
     * Add the given attribute if {@code value => 0}.
     *
     * @param name
     * @param value
     * @return a reference to this object
     */
    public func optIntAttribute(name: String, value: Int): XmlStringBuilder {
        if (value >= 0) {
            attribute(name, value.toString())
        }
        return this
    }

    /**
     * If the provided Integer argument is not None,
     * then add a new XML attribute with the given name and the Integer as value.
     *
     * @param name the XML attribute name.
     * @param value the optional integer to use as the attribute's value.
     * @return a reference to this object.
     */
    public func optIntAttribute(name: String, value: ?Int): XmlStringBuilder {
        if (let Some(value) <- value) {
            if (value > 0) {
                attribute(name, value.toString())
            }
        }
        return this
    }

    public func optBooleanAttribute(name: String, bool: Bool): XmlStringBuilder {
        if (bool) {
            sb.append(' ').append(name).append("='true'")
        }
        return this
    }

    public func optBooleanAttributeDefaultTrue(name: String, bool: Bool): XmlStringBuilder {
        if (!bool) {
            sb.append(' ').append(name).append("='false'")
        }
        return this
    }

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

    public func xmllangAttribute(value: ?String): XmlStringBuilder {
        optAttribute("xml:lang", value)
        return this
    }

    public func optXmlLangAttribute(lang: ?String): XmlStringBuilder {
        if (!StringUtils.isNullOrEmpty(lang)) {
            xmllangAttribute(lang.getOrThrow())
        }
        return this
    }

    public func text(text: ToString): XmlStringBuilder {
        let escapedText = StringUtils.escapeForXmlText(text.toString())
        sb.append(escapedText)
        return this
    }

    public func escape(text: String): XmlStringBuilder {
        sb.append(StringUtils.escapeForXml(text))
        return this
    }

    public func escapeAttributeValue(value: String): XmlStringBuilder {
        sb.append(StringUtils.escapeForXmlAttributeApos(value))
        return this
    }

    public func optEscape(text: ?ToString): XmlStringBuilder {
        if (let Some(text) <- text) {
            return escape(text.toString())
        }
        return this
    }

    public func escape(text: ToString): XmlStringBuilder {
        return escape(text.toString())
    }

    protected func prelude(pe: FullyQualifiedElement): XmlStringBuilder {
        return prelude(pe.getElementName(), pe.getNamespace())
    }

    protected func prelude(elementName: String, namespace: String): XmlStringBuilder {
        halfOpenElement(elementName)
        xmlnsAttribute(namespace)
        return this
    }

    public func optAppend(element: ?Element): XmlStringBuilder {
        if (let Some(element) <- element) {
            append(element.toXML(effectiveXmlEnvironment))
        }
        return this
    }

    public func optAppend(elements: ?Iterator<Element>): XmlStringBuilder {
        if (let Some(elements) <- elements) {
            append(elements)
        }
        return this
    }

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

    public func append(xsb: XmlStringBuilder): XmlStringBuilder {
        sb.append(xsb.sb)
        return this
    }

    public func append(element: Element): XmlStringBuilder {
        append(element.toXML(effectiveXmlEnvironment))
        return this
    }

    public func append(elements: Iterator<Element>): XmlStringBuilder {
        for (element in elements) {
            append(element)
        }
        return this
    }

    public func emptyElement(element: ToString): XmlStringBuilder {
        return emptyElement(element.toString())
    }

    public func emptyElement(element: String): XmlStringBuilder {
        halfOpenElement(element)
        return closeEmptyElement()
    }

    public func condEmptyElement(condition: Bool, element: ?String): XmlStringBuilder {
        if (condition) {
            emptyElement(element)
        }
        return this
    }

    public func condAttribute(condition: Bool, name: String, value: ?String): XmlStringBuilder {
        if (condition) {
            attribute(name, value)
        }
        return this
    }

    public override func append(csq: CharSequence): Appendable {
        sb.append(csq)
        return this
    }

    /*
    override public  func append(csq: String, start: Int, end: Int): XmlStringBuilder {
        sb.append(csq, start, end)
        return this
    }

    override public  func append(c: Rune): XmlStringBuilder {
        sb.append(c)
        return this
    }


    override public  func charAt(index: Int): Char {
        return sb.charAt(index)
    }

    override public  func subSequence(start: Int, end: Int): ?String {
        return sb.subSequence(start, end)
    }


    override public  func equals(other: ?Object): Bool {
        if (!(ValueBox<String>.check(other))) {
            return false
        }
        let otherCharSequenceBuilder = ValueBox<String>.cast(other)
        return <-- No type transform for: toString().<-- Мapping is present but failed: equals -->(toString(otherCharSequenceBuilder)) : Any -> Bool -->
    }

    override public  func hashCode(): Int64 {
        return toString().hashCode()
    }
     */
    public prop size: Int {
        get() {
            sb.size
        }
    }

    public override func toString(): String {
        return sb.toString()
    }

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
}
