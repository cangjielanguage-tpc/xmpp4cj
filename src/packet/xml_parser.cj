/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class XmppXmlParser {
    private static var xmlPullParserFactory: ?XmlPullParserFactory = None // TODO

    public static func getXmlPullParserFactory(): XmlPullParserFactory {
        return xmlPullParserFactory ?? throw Exception("No XmlPullParserFactory registered")
    }

    public static func setXmlPullParserFactory(xmlPullParserFactory: XmlPullParserFactory) {
        XmppXmlParser.xmlPullParserFactory = xmlPullParserFactory
    }

    /**
     * Creates a new XmlPullParser suitable for parsing XMPP.
     * This means in particular that FEATURE_PROCESS_NAMESPACES is enabled.
     * <p>
     * Note that not all XmlPullParser implementations will return a String on
     * <code>getText()</code> if the parser is on START_ELEMENT or END_ELEMENT.
     * So you must not rely on this behavior when using the parser.
     * </p>
     *
     * @param reader a reader to read the XML data from.
     * @return A suitable XmlPullParser for XMPP parsing.
     * @throws XmlPullParserException in case of an XmlPullParserException.
     */
    public static func newXmlParser(reader: StringReader<InputStream>): XmlPullParser {
        let xmlPullParserFactory = getXmlPullParserFactory()
        return xmlPullParserFactory.newXmlPullParser(reader)
    }
}

/**
 * Xmpp's interface for XML pull parsers.
 *
 * <p>
 * Differences from StAX's XMLStreamReader are:
 * </p>
 * <ul>
 *  <li>{@link #getName()} and {@link #getAttributeName(int)} return localname, there is {@link #getQName()} and {@link #getAttributeQName(int)} to retrieve the qualified name ({@link QName}).</li>
 *  <li>{@link #nextText()} instead of {@code XMLStreamReader.getElementText()}.
 * </ul>
 * <p>
 * Differences from XPP3's XmlPullParser are:
 * </p>
 * <ul>
 *  <li>Methods taking an attribute, like {@link #getAttributeName(int)} index return <code>None</code> instead of throwing an exception if no attribute with the given index exists.</li>
 * </ul>
 *
 * <h2>Developer Information</h2>
 * <p>
 * The following table shows the mapping of Xmpp's XmlPullParser events to StAX and XPP3 events:
 * </p>
 * <table>
 * <caption>XmlPullParser event mapping</caption>
 * <tr><th>Xmpp's {@link XmlPullParserEvent}</th><th>StAX Event</th><th>XPP3 Event</th></tr>
 * <tr><td>{@link XmlPullParserEvent#START_DOCUMENT}</td><td>START_DOCUMENT (7)</td><td>START_DOCUMENT (0)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#END_DOCUMENT}</td><td>END_DOCUMENT (8)</td><td>END_DOCUMENT (1)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#START_ELEMENT}</td><td>START_ELEMENT (1)</td><td>START_TAG (2)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#END_ELEMENT}</td><td>END_ELEMENT (2)</td><td>END_TAG (3)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#TEXT_CHARACTERS}</td><td>CHARACTERS (4)</td><td>TEXT (4)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#PROCESSING_INSTRUCTION}</td><td>PROCESSING_INSTRUCTION (3)</td><td>PROCESSING_INSTRUCTION (8)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#COMMENT}</td><td>COMMENT (5)</td><td>COMMENT (9)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#IGNORABLE_WHITESPACE}</td><td>SPACE (6)</td><td>IGNORABLE_WHITESPACE (7)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#ENTITY_REFERENCE}</td><td>ENTITY_REFERENCE (9)</td><td>ENTITY_REF (6)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#OTHER}</td><td>ENTITY_REFERENCE (9)</td><td>ENTITY_REF (6)</td></tr>
 * </table>
 * <p>{@link XmlPullParserEvent#OTHER} includes
 * in case of StAX: ATTRIBUTE (10), DTD (11), CDATA (12), NAMESPACE (13), NOTATION_DECLARATION (14) and ENTITY_DECLRATION (15),
 * in case of XPP3: CDSECT (5), DOCDECL (10).
 * </p>
 *
 */
public interface XmlPullParser {
    func getProperty(name: String): Object

    func getInputEncoding(): String

    func getNamespaceCount(): Int64

    func getNamespacePrefix(pos: Int64): String

    func getNamespaceUri(pos: Int64): String

    func getNamespace(prefix: ?String): String

    func getDefaultNamespace(): String {
        return getNamespace(None)
    }

    func getDepth(): Int64

    func getPositionDescription(): String

    func getLineNumber(): Int64

    func getColumnNumber(): Int64

    func isWhiteSpace(): Bool

    func getText(): String

    func getNamespace(): String

    /**
     * Return the name for the current START_ELEMENT or END_ELEMENT event.
     * This method must only be called if the current event is START_ELEMENT or END_ELEMENT.
     *
     * @return the name for the current START_ELEMETN or END_ELEMENT event.
     */
    func getName(): String

    func getQName(): QName

    func getPrefix(): String

    func getAttributeCount(): Int64

    func getAttributeNamespace(index: Int64): String

    /**
     * Returns the loacalpart of the attribute's name or <code>None</code>
     * in case the index does not refer to an attribute.
     *
     * @param index the attribute index.
     * @return the localpart of the attribute's name or <code>None</code>.
     */
    func getAttributeName(index: Int64): String

    func getAttributeQName(index: Int64): QName

    func getAttributePrefix(index: Int64): String

    func getAttributeType(index: Int64): String

    func getAttributeValue(index: Int64): String

    func getAttributeValue(namespace: ?String, name: String): String

    func getAttributeValue(name: String): String {
        return getAttributeValue(None, name)
    }

    func getEventType(): XmlPullParserEvent

    func next(): XmlPullParserEvent

    /**
     * Reads the content of a text-only element,
     * an exception is thrown if this is not a text-only element.
     * <ul>
     *   <li>Precondition: the current event is START_ELEMENT.</li>
     *   <li>Postcondition: the current event is the corresponding END_ELEMENT.</li>
     * </ul>
     *
     * @return the textual content of the current element.
     * @throws IOException in case of an IO error.
     * @throws XmlPullParserException in case of an XML pull parser error.
     */
    func nextText(): String

    func nextTag(): XmlPullParserTagEvent

    func supportsRoundtrip(): Bool
}

public enum XmlPullParserTagEvent {
    START_ELEMENT
    | END_ELEMENT
}

public enum XmlPullParserEvent <: Equatable<XmlPullParserEvent> {
    START_DOCUMENT
    | END_DOCUMENT
    | START_ELEMENT
    | END_ELEMENT
    /**
     * Replaces TEXT from XPP3.
     */
    | TEXT_CHARACTERS
    | PROCESSING_INSTRUCTION
    | COMMENT
    | IGNORABLE_WHITESPACE
    | ENTITY_REFERENCE
    | OTHER

    public operator func ==(other: XmlPullParserEvent): Bool {
        match ((this, other)) {
            case (START_DOCUMENT, START_DOCUMENT) => true
            case (END_DOCUMENT, END_DOCUMENT) => true
            case (START_ELEMENT, START_ELEMENT) => true
            case (END_ELEMENT, END_ELEMENT) => true
            case (TEXT_CHARACTERS, TEXT_CHARACTERS) => true
            case (PROCESSING_INSTRUCTION, PROCESSING_INSTRUCTION) => true
            case (COMMENT, COMMENT) => true
            case (IGNORABLE_WHITESPACE, IGNORABLE_WHITESPACE) => true
            case (ENTITY_REFERENCE, ENTITY_REFERENCE) => true
            case (OTHER, OTHER) => true
            case _ => false
        }
    }
    public operator func !=(other: XmlPullParserEvent): Bool {
        !(this == other)
    }
}

public interface XmlPullParserFactory {
    func newXmlPullParser(reader: StringReader<InputStream>): XmlPullParser
}

public class XmlPullParserException <: Exception {
    public init(wrapped: Exception) {
        super(wrapped.toString())
    }

    public init(message: String) {
        super(message)
    }
}
