/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public interface IqView <: StanzaView & ToString {
    /**
     * Returns the type of the IQ packet.
     *
     * @return the type of the IQ packet.
     */
    func getType(): IQType

    /**
     * Return true if this IQ is a request IQ, i.e. an IQ of type {@link Type#get} or {@link Type#set}.
     *
     * @return true if IQ type is 'get' or 'set', false otherwise.
     */
    func isRequestIQ(): Bool {
        let typ = getType()
        return typ == IQType.get || typ == IQType.set
    }

    /**
     * Return true if this IQ is a response IQ, i.e. an IQ of type {@link Type#result} or {@link Type#error}.
     *
     * @return true if IQ type is 'result' or 'error', false otherwise.
     */
    func isResponseIQ(): Bool {
        return !isRequestIQ()
    }
}

/**
 * The base IQ (Info/Query) packet. IQ packets are used to get and set information
 * on the server, including authentication, roster operations, and creating
 * accounts. Each IQ stanza has a specific type that indicates what type of action
 * is being taken: "get", "set", "result", or "error".<p>
 *
 * IQ packets can contain a single child element that exists in a specific XML
 * namespace. The combination of the element name and namespace determines what
 * type of IQ stanza it is. Some example IQ subpacket snippets:<ul>
 *
 *  <li>&lt;query xmlns="jabber:iq:auth"&gt; -- an authentication IQ.
 *  <li>&lt;query xmlns="jabber:iq:private"&gt; -- a private storage IQ.
 *  <li>&lt;pubsub xmlns="${JABBER_PROTOCAL_NAMESPACE_PREFIX}/pubsub"&gt; -- a pubsub IQ.
 * </ul>
 */
public abstract class IQ <: Stanza & IqView {
    // Don't name this field 'ELEMENT'. When it comes to IQ, ELEMENT is the child element!
    public static let IQ_ELEMENT = "iq"
    public static let QUERY_ELEMENT = "query"

    private let childElementQName: QName
    private let childElementName: String
    private let childElementNamespace: String
    protected var typ: IQType = IQType.get

    protected init(iq: IQ) {
        super(iq)
        typ = iq.getType()
        this.childElementName = iq.childElementName
        this.childElementNamespace = iq.childElementNamespace
        this.childElementQName = iq.childElementQName
    }

    protected init(childElementName: String, childElementNamespace: String) {
        this(IqData.EMPTY, childElementName, childElementNamespace)
    }

    protected init(iqBuilder: AbstractIqBuilder, childElementName: String, childElementNamespace: String) {
        this(
            iqBuilder,
            if (childElementName == EMPTY_ELEMENT) {
                EMPTY_QNAME
            } else {
                QName(childElementNamespace, childElementName)
            }
        )
    }

    protected init(iqBuilder: AbstractIqBuilder, childElementQName: ?QName) {
        super(iqBuilder)
        typ = iqBuilder.typ
        if (let Some(childElementQName) <- childElementQName) {
            this.childElementQName = childElementQName
            this.childElementName = childElementQName.getLocalPart()
            this.childElementNamespace = childElementQName.getNamespaceURI()
        } else {
            this.childElementQName = EMPTY_QNAME
            this.childElementName = EMPTY_ELEMENT
            this.childElementNamespace = EMPTY_NAMESPACE
        }
    }

    public override func getType(): IQType {
        return typ
    }

    /**
     * Sets the type of the IQ packet.
     * <p>
     * Since the type of an IQ must present, an IllegalArgmentException will be thrown when type is
     * <code>None</code>.
     * </p>
     *
     * @param type the type of the IQ packet.
     */
    public func setType(typ: IQType): Unit {
        this.typ = typ
    }

    public func getChildElementQName(): QName {
        return childElementQName
    }

    public func getChildElementName(): String {
        return childElementName
    }

    public func getChildElementNamespace(): String {
        return childElementNamespace
    }

    public override func getElementName(): String {
        return IQ_ELEMENT
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("IQ Stanza (")
        sb.append(getChildElementName())
        sb.append(' ')
        sb.append(getChildElementNamespace())
        sb.append(") [")
        logCommonAttributes(sb)
        sb.append("type=")
        sb.append(typ.toString())
        sb.append(',')
        sb.append(']')
        return sb.toString()
    }

    public override func toXML(enclosingXmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let buf = XmlStringBuilder(this, enclosingXmlEnvironment)
        addCommonAttributes(buf)
        buf.attribute("type", typ.toString())
        buf.rightAngleBracket()
        appendInnerXml(buf)
        buf.closeElement(IQ_ELEMENT)
        return buf
    }

    /**
     * Returns the sub-element XML section of the IQ packet,
     * or the empty String if there isn't one.
     *
     * @return the child element section of the IQ XML.
     */
    public func getChildElementXML(): XmlStringBuilder {
        let xml = XmlStringBuilder()
        appendInnerXml(xml)
        return xml
    }

    /**
     * Append the sub-element XML section of the IQ stanza.
     *
     * @param xml the XmlStringBuilder to append to.
     */
    private func appendInnerXml(xml: XmlStringBuilder): Unit {
        if (typ == IQType.error) {
            appendErrorIfExists(xml)
        }
        if (childElementName.size == 0) {
            return
        }

        // Add the query section if there is one.
        let iqChildElement = if (let Some(v) <- getIQChildElementBuilder(
            IQChildElementXmlStringBuilder(getChildElementName(), getChildElementNamespace(), None,
            xml.getXmlEnvironment()))) {
            v
        } else {
            return
        }
        xml.append(iqChildElement)
        let extensionsXml = getExtensions()
        if (iqChildElement.isEmptyElement) {
            if (extensionsXml.isEmpty()) {
                xml.closeEmptyElement()
                return
            }
            xml.rightAngleBracket()
        }
        xml.append(extensionsXml |> map<ExtensionElement, Element> {v => v})
        xml.closeElement(iqChildElement.elementName)
    }

    /**
     * This method must be overwritten by IQ subclasses to create their child content. It is important you don't use the builder
     * <b>to add the final end tag</b>. This will be done automatically by {@link IQChildElementXmlStringBuilder}
     * after eventual existing {@link ExtensionElement}s have been added.
     * <p>
     * For example to create an IQ with a extra attribute and an additional child element
     * </p>
     * <pre>
     * {@code
     * <iq to='foo@example.org' id='123'>
     *   <bar xmlns='example:bar' extraAttribute='blaz'>
     *      <extraElement>elementText</extraElement>
     *   </bar>
     * </iq>
     * }
     * </pre>
     * the body of the {@code getIQChildElementBuilder} looks like
     * <pre>
     * {@code
     * // The builder 'xml' will already have the child element and the 'xmlns' attribute added
     * // So the current builder state is "<bar xmlns='example:bar'"
     * xml.attribute("extraAttribute", "blaz");
     * xml.rightAngleBracket();
     * xml.element("extraElement", "elementText");
     * // Do not close the 'bar' attribute by calling xml.closeElement('bar')
     * }
     * </pre>
     * If your IQ only contains attributes and no child elements, i.e. it can be represented as empty element, then you
     * can mark it as such.
     * <pre>
     * xml.attribute(&quot;myAttribute&quot;, &quot;myAttributeValue&quot;);
     * xml.setEmptyElement();
     * </pre>
     * If your IQ does not contain any attributes or child elements (besides {@link ExtensionElement}s), consider sub-classing
     * {@link SimpleIQ} instead.
     *
     * @param xml a pre-created builder which already has the child element and the 'xmlns' attribute set.
     * @return the build to create the IQ child content.
     */
    protected func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder

    /**
     * Convenience method to create a new empty {@link Type#result IQType.result}
     * IQ based on a {@link Type#get IQType.get} or {@link Type#set IQType.set}
     * IQ. The new stanza will be initialized with:<ul>
     *      <li>The sender set to the recipient of the originating IQ.
     *      <li>The recipient set to the sender of the originating IQ.
     *      <li>The type set to {@link Type#result IQType.result}.
     *      <li>The id set to the id of the originating IQ.
     *      <li>No child element of the IQ element.
     * </ul>
     *
     * @param request the {@link Type#get IQType.get} or {@link Type#set IQType.set} IQ packet.
     * @throws IllegalArgumentException if the IQ stanza does not have a type of
     *      {@link Type#get IQType.get} or {@link Type#set IQType.set}.
     * @return a new {@link Type#result IQType.result} IQ based on the originating IQ.
     */
    public static func createResultIQ(request: IQ): IQ {
        return EmptyResultIQ(request)
    }

    /**
     * Convenience method to create a new {@link Type#error IQType.error} IQ
     * based on a {@link Type#get IQType.get} or {@link Type#set IQType.set}
     * IQ. The new stanza will be initialized with:<ul>
     *      <li>The sender set to the recipient of the originating IQ.
     *      <li>The recipient set to the sender of the originating IQ.
     *      <li>The type set to {@link Type#error IQType.error}.
     *      <li>The id set to the id of the originating IQ.
     *      <li>The child element contained in the associated originating IQ.
     *      <li>The provided {@link StanzaError XMPPError}.
     * </ul>
     *
     * @param request the {@link Type#get IQType.get} or {@link Type#set IQType.set} IQ packet.
     * @param error the error to associate with the created IQ packet.
     * @throws IllegalArgumentException if the IQ stanza does not have a type of
     *      {@link Type#get IQType.get} or {@link Type#set IQType.set}.
     * @return a new {@link Type#error IQType.error} IQ based on the originating IQ.
     */
    public static func createErrorResponse(request: IQ, error: StanzaError): ErrorIQ {
        return ErrorIQ.createErrorResponse(request, error)
    }

    public static func createErrorResponse(request: IQ, condition: StanzaErrorCondition): ErrorIQ {
        return createErrorResponse(request, StanzaError.getBuilder(condition).build())
    }
}

/**
 * A enum to represent the type of the IQ stanza.
 */
public enum IQType <: ToString & Equatable<IQType> {
    /**
     * The IQ stanza requests information, inquires about what data is needed in order to complete further operations, etc.
     */
    get
    /**
     * The IQ stanza provides data that is needed for an operation to be completed, sets new values, replaces existing values, etc.
     */
    | set
    /**
     * The IQ stanza is a response to a successful get or set request.
     */
    | result
    /**
     * The IQ stanza reports an error that has occurred regarding processing or delivery of a get or set request.
     */
    | error

    /**
     * Converts a String into the corresponding types. Valid String values
     * that can be converted to types are: "get", "set", "result", and "error".
     *
     * @param string the String value to covert.
     * @return the corresponding Type.
     * @throws IllegalArgumentException when not able to parse the string parameter
     */
    public static func fromString(string: String): IQType {
        match (string.toAsciiLower()) {
            case "get" => get
            case "set" => set
            case "result" => result
            case "error" => error
            case _ => throw IllegalArgumentException("Invalid IQType: ${string}")
        }
    }

    public override func toString(): String {
        return match (this) {
            case get => "get"
            case set => "set"
            case result => "result"
            case error => "error"
        }
    }

    public operator func ==(that: IQType): Bool {
        return match ((this, that)) {
            case (get, get) => true
            case (set, set) => true
            case (result, result) => true
            case (error, error) => true
            case _ => false
        }
    }

    public operator func !=(that: IQType): Bool {
        return !(this == that)
    }
}

public enum IQResponseType <: ToString & Equatable<IQResponseType> {
    result
    | error

    func getType(): IQType {
        match (this) {
            case result => IQType.result
            case error => IQType.error
        }
    }

    public override func toString(): String {
        return match (this) {
            case result => "result"
            case error => "error"
        }
    }

    public operator func ==(that: IQResponseType): Bool {
        match ((this, that)) {
            case (result, result) => true
            case (error, error) => true
            case _ => false
        }
    }

    public operator func !=(that: IQResponseType): Bool {
        return !(this == that)
    }
}

public class IQChildElementXmlStringBuilder <: XmlStringBuilder {
    var elementName: String = EMPTY_ELEMENT
    var isEmptyElement: Bool = false

    public init(extensionElement: ExtensionElement, enclosingXmlEnvironment: ?XmlEnvironment) {
        this(
            extensionElement.getElementName(),
            extensionElement.getNamespace(),
            extensionElement.getLanguage(),
            enclosingXmlEnvironment
        )
    }

    init(elementName: String, xmlNs: String, xmlLang: ?String, enclosingXmlEnvironment: ?XmlEnvironment) {
        super(elementName, xmlNs, xmlLang, enclosingXmlEnvironment)
        this.elementName = elementName
    }

    public func setEmptyElement(): Unit {
        isEmptyElement = true
    }
}
