/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * Utility class that helps to parse packets. Any parsing packets method that must be shared
 * between many clients must be placed in this utility class.
 */
public class PacketParserUtils {
    private static let LOGGER = getGlobalLogger(("name", "PacketParserUtils"))

    public static func getParserFor(stanza: String): XmlPullParser {
        let input = ByteArrayStream()
        input.write(stanza.toArray())
        return getParserFor(input)
    }

    public static func getParserFor(inputStream: InputStream): XmlPullParser {
        var parser: XmlPullParser = XmppXmlParser.newXmlParser(inputStream)
        ParserUtils.forwardToStartElement(parser)
        return parser
    }

    /**
     * Tries to parse and return either a Message, IQ or Presence stanza.
     *
     * connection is optional and is used to return feature-not-implemented errors for unknown IQ stanzas.
     *
     * @param parser TODO javadoc me please
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return a stanza which is either a Message, IQ or Presence.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     * @throws IOException if an I/O error occurred.
     */
    public static func parseStanza<S>(stanza: String): S where S <: Stanza {
        return (parseStanza(getParserFor(stanza), XmlEnvironment.EMPTY) as S).getOrThrow()
    }

    public static func parseStanza(parser: XmlPullParser, outerXmlEnvironment: XmlEnvironment): Stanza {
        ParserUtils.assertAtStartTag(parser)
        let name = parser.getName()
        match (name) {
            case v where v == Message.ELEMENT => return castOrThrow<Message, Stanza>(
                parseMessage(parser, outerXmlEnvironment))
            case v where v == IQ.IQ_ELEMENT => return castOrThrow<IQ, Stanza>(parseIQ(parser, outerXmlEnvironment))
            case v where v == Presence.ELEMENT => return castOrThrow<Presence, Stanza>(
                parsePresence(parser, outerXmlEnvironment))
            case _ => throw IllegalArgumentException("Can only parse message, iq or presence, not " + (name))
        }
    }

    private static func parseCommonStanzaAttributes<SB>(stanzaBuilderSupplier: (?String) -> SB, parser: XmlPullParser,
        xmlEnvironment: XmlEnvironment): SB where SB <: StanzaBuilder {
        let id = parser.getAttributeValue("id")
        let stanzaBuilder: SB = stanzaBuilderSupplier(id)
        let to = ParserUtils.getJidAttribute(parser, "to")
        stanzaBuilder.to(to)
        let froms = ParserUtils.getJidAttribute(parser, "from")
        stanzaBuilder.froms(froms)
        let language = ParserUtils.getXmlLang(parser, xmlEnvironment)
        stanzaBuilder.setLanguage(language)
        return stanzaBuilder
    }

    public static func parseMessage(parser: XmlPullParser): Message {
        return parseMessage(parser, XmlEnvironment.EMPTY)
    }

    /**
     * Parses a message packet.
     *
     * @param parser the XML parser, positioned at the start of a message packet.
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return a Message packet.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws IOException if an I/O error occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     */
    public static func parseMessage(parser: XmlPullParser, outerXmlEnvironment: XmlEnvironment): Message {
        ParserUtils.assertAtStartTag(parser)
        if (parser.getName() != Message.ELEMENT) {
            throw Exception("AssertionError")
        }
        let messageXmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)
        let initialDepth = parser.getDepth()
        let message: MessageBuilder = parseCommonStanzaAttributes({id => StanzaBuilder.buildMessage(id)}, parser,
            outerXmlEnvironment)
        let typeString = parser.getAttributeValue("", "type")
        if (let Some(typeString) <- typeString) {
            message.ofType(MessageType.fromString(typeString))
        }

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let elementName = parser.getName()
                    let namespace = parser.getNamespace()
                    match (elementName) {
                        case "error" => message.setError(parseError(parser, messageXmlEnvironment))
                        case _ =>
                            let extensionElement = parseExtensionElement(elementName, namespace, parser,
                                messageXmlEnvironment)
                            message.addExtension(extensionElement)
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        return message.build()
    }

    /**
     * Returns the textual content of an element as String. After this method returns the parser
     * position will be END_ELEMENT, following the established pull parser calling convention.
     * <p>
     * The parser must be positioned on a START_ELEMENT of an element which MUST NOT contain Mixed
     * Content (as defined in XML 3.2.2), or else an XmlPullParserException will be thrown.
     * </p>
     * This method is used for the parts where the XMPP specification requires elements that contain
     * only text or are the empty element.
     *
     * @param parser TODO javadoc me please
     * @return the textual content of the element as String
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws IOException if an I/O error occurred.
     */
    public static func parseElementText(parser: XmlPullParser): String {
        if (parser.getEventType() != XmlPullParserEvent.START_ELEMENT) {
            throw Exception("AssertionError")
        }
        let res: String
        var event = parser.next()
        if (event != XmlPullParserEvent.TEXT_CHARACTERS) {
            if (event == XmlPullParserEvent.END_ELEMENT) {
                return ""
            } else {
                throw XmlPullParserException(
                    "Non-empty element tag not followed by text, while Mixed Content (XML 3.2.2) is disallowed")
            }
        }
        res = parser.getText()
        event = parser.next()
        if (event != XmlPullParserEvent.END_ELEMENT) {
            throw XmlPullParserException(
                "Non-empty element tag contains child-elements, while Mixed Content (XML 3.2.2) is disallowed")
        }
        return res
    }

    /**
     * Returns the current element as string.
     * <p>
     * The parser must be positioned on START_ELEMENT.
     * </p>
     * Note that only the outermost namespace attributes ("xmlns") will be returned, not nested ones.
     *
     * @param parser the XML pull parser
     * @return the element as string
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws IOException if an I/O error occurred.
     */
    public static func parseElement(parser: XmlPullParser): String {
        return parseElement(parser, false)
    }

    public static func parseElement(parser: XmlPullParser, fullNamespaces: Bool): String {
        if (parser.getEventType() != XmlPullParserEvent.START_ELEMENT) {
            throw Exception("AssertionError")
        }
        return parseContentDepth(parser, parser.getDepth(), fullNamespaces)
    }

    /**
     * Returns the content from the current position of the parser up to the closing tag of the
     * given depth. Note that only the outermost namespace attributes ("xmlns") will be returned,
     * not nested ones, if <code>fullNamespaces</code> is false. If it is true, then namespaces of
     * parent elements will be added to child elements that don't define a different namespace.
     * <p>
     * This method is able to parse the content with MX- and KXmlParser. KXmlParser does not support
     * xml-roundtrip. i.e. return a String on getText() on START_ELEMENT and END_ELEMENT. We check for the
     * XML_ROUNDTRIP feature. If it's not found we are required to work around this limitation, which
     * results in only partial support for XML namespaces ("xmlns"): Only the outermost namespace of
     * elements will be included in the resulting String, if <code>fullNamespaces</code> is set to false.
     * </p>
     * <p>
     * In particular Android's XmlPullParser does not support XML_ROUNDTRIP.
     * </p>
     *
     * @param parser TODO javadoc me please
     * @param depth TODO javadoc me please
     * @param fullNamespaces TODO javadoc me please
     * @return the content of the current depth
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws IOException if an I/O error occurred.
     */
    public static func parseContentDepth(parser: XmlPullParser, depth: Int): String {
        return parseContentDepth(parser, depth, false)
    }

    /**
     * Returns the content from the current position of the parser up to the closing tag of the
     * given depth. Note that only the outermost namespace attributes ("xmlns") will be returned,
     * not nested ones, if <code>fullNamespaces</code> is false. If it is true, then namespaces of
     * parent elements will be added to child elements that don't define a different namespace.
     * <p>
     * This method is able to parse the content with MX- and KXmlParser. KXmlParser does not support
     * xml-roundtrip. i.e. return a String on getText() on START_ELEMENT and END_ELEMENT. We check for the
     * XML_ROUNDTRIP feature. If it's not found we are required to work around this limitation, which
     * results in only partial support for XML namespaces ("xmlns"): Only the outermost namespace of
     * elements will be included in the resulting String, if <code>fullNamespaces</code> is set to false.
     * </p>
     * <p>
     * In particular Android's XmlPullParser does not support XML_ROUNDTRIP.
     * </p>
     *
     * @param parser TODO javadoc me please
     * @param depth TODO javadoc me please
     * @param fullNamespaces TODO javadoc me please
     * @return the content of the current depth
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws IOException if an I/O error occurred.
     */
    public static func parseContentDepth(parser: XmlPullParser, depth: Int, fullNamespaces: Bool): String {
        if (parser.supportsRoundtrip()) {
            return parseContentDepthWithRoundtrip(parser, depth).toString()
        } else {
            return parseContentDepthWithoutRoundtrip(parser, depth, fullNamespaces)
        }
    }

    private static func parseContentDepthWithoutRoundtrip(parser: XmlPullParser, depth: Int, fullNamespaces: Bool): String {
        let xml = XmlStringBuilder()
        var event = parser.getEventType()
        var namespaceElement: ?String = None
        var startElementJustSeen = false
        while (true) {
            match (event) {
                case XmlPullParserEvent.START_ELEMENT =>
                    if (startElementJustSeen) {
                        xml.rightAngleBracket()
                    } else {
                        startElementJustSeen = true
                    }
                    xml.halfOpenElement(parser.getName())
                    if (namespaceElement.isNone() || fullNamespaces) {
                        let namespace = parser.getNamespace()
                        if (StringUtils.isNotEmpty(namespace)) {
                            xml.attribute("xmlns", namespace)
                            namespaceElement = parser.getName()
                        }
                    }
                    var i = 0
                    while (i < parser.getAttributeCount()) {
                        xml.attribute(parser.getAttributeName(i), parser.getAttributeValue(i))
                        i++
                    }
                case XmlPullParserEvent.END_ELEMENT =>
                    if (startElementJustSeen) {
                        xml.closeEmptyElement()
                        startElementJustSeen = false
                    } else {
                        xml.closeElement(parser.getName())
                    }
                    if (namespaceElement.isSome() && namespaceElement == parser.getName()) {
                        namespaceElement = None
                    }
                    if (parser.getDepth() <= depth) {
                        break
                    }
                case XmlPullParserEvent.TEXT_CHARACTERS =>
                    if (startElementJustSeen) {
                        startElementJustSeen = false
                        xml.rightAngleBracket()
                    }
                    xml.escape(parser.getText())
                case _ => ()
            }
            event = parser.next()
        }
        return xml.toString()
    }

    private static func parseContentDepthWithRoundtrip(parser: XmlPullParser, depth: Int): XmlStringBuilder {
        let sb = XmlStringBuilder()
        var event = parser.getEventType()
        var startElementJustSeen = false
        while (true) {
            match (event) {
                case XmlPullParserEvent.START_ELEMENT =>
                    startElementJustSeen = true
                    let openElementTag = parser.getText()
                    sb.append(openElementTag)
                case XmlPullParserEvent.END_ELEMENT =>
                    var isEmptyElement = false
                    if (startElementJustSeen) {
                        isEmptyElement = true
                        startElementJustSeen = false
                    }
                    if (!isEmptyElement) {
                        let text = parser.getText()
                        sb.append(text)
                    }
                    if (parser.getDepth() <= depth) {
                        break
                    }
                case _ =>
                    startElementJustSeen = false
                    var text = parser.getText()
                    if (event == XmlPullParserEvent.TEXT_CHARACTERS) {
                        text = StringUtils.escapeForXml(text)
                    }
                    sb.append(text)
            }
            event = parser.next()
        }
        return sb
    }

    public static func parsePresence(parser: XmlPullParser): Presence {
        return parsePresence(parser, XmlEnvironment.EMPTY)
    }

    /**
     * Parses a presence packet.
     *
     * @param parser the XML parser, positioned at the start of a presence packet.
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return a Presence packet.
     * @throws IOException if an I/O error occurred.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     */
    public static func parsePresence(parser: XmlPullParser, outerXmlEnvironment: XmlEnvironment): Presence {
        ParserUtils.assertAtStartTag(parser)
        let initialDepth = parser.getDepth()
        let presenceXmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)
        let presence: PresenceBuilder = parseCommonStanzaAttributes({stanzaId => StanzaBuilder.buildPresence(stanzaId)},
            parser, outerXmlEnvironment)
        var Type: PresenceType = PresenceType.available
        let typeString = parser.getAttributeValue("", "type") ?? "\0"
        if (typeString != "\0" && typeString != "") {
            Type = PresenceType.fromString(typeString)
        }
        presence.ofType(Type)

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let elementName = parser.getName()
                    let namespace = parser.getNamespace()
                    match (elementName) {
                        case "status" => presence.setStatus(parser.nextText())
                        case "priority" =>
                            let priority = ParserUtils.getByteAttributeFromNextText(parser)
                            presence.setPriority(priority)
                        case "show" =>
                            let modeText = parser.nextText()
                            if (StringUtils.isNotEmpty(modeText)) {
                                presence.setMode(PresenceMode.fromString(modeText))
                            } else {
                                LOGGER.warn(
                                    "Empty or null mode text in presence show element form ${presence as ToString}' which is invalid according to RFC6121 4.7.2.1"
                                )
                            }
                        case "error" => presence.setError(parseError(parser, presenceXmlEnvironment))
                        case _ => try {
                            let extensionElement = parseExtensionElement(elementName, namespace, parser,
                                presenceXmlEnvironment)
                            presence.addExtension(extensionElement)
                        } catch (e: Exception) {
                            LOGGER.log(
                                LogLevel.WARN,
                                "Failed to parse extension element in Presence stanza: ${presence as ToString}",
                                ("Exception", e)
                            )
                        }
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        return presence.build()
    }

    /**
     * Parses an IQ packet.
     *
     * @param parser the XML parser, positioned at the start of an IQ packet.
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return an IQ object.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws XmppStringprepException if the provided string is invalid.
     * @throws IOException if an I/O error occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     */
    public static func parseIQ(parser: XmlPullParser): IQ {
        return parseIQ(parser, None)
    }

    public static func parseIqData(parser: XmlPullParser): IqData {
        let id = parser.getAttributeValue("", "id")
        let iqData = StanzaBuilder.buildIqData(id)
        let to = ParserUtils.getJidAttribute(parser, "to")
        iqData.to(to)
        let froms = ParserUtils.getJidAttribute(parser, "from")
        iqData.froms(froms)
        let typeString = parser.getAttributeValue("", "type") ?? ""
        let Type = IQType.fromString(typeString)
        iqData.ofType(Type)
        return iqData
    }

    public static func parseIQ(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): IQ {
        ParserUtils.assertAtStartTag(parser)
        let initialDepth = parser.getDepth()
        let iqXmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)
        var iqPacket: ?IQ = None
        var error: ?StanzaError = None
        let iqData = parseIqData(parser)

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let elementName = parser.getName()
                    let namespace = parser.getNamespace()
                    match (elementName) {
                        case "error" => error = PacketParserUtils.parseError(parser, iqXmlEnvironment)
                        case _ =>
                            let provider = ProviderManager.getIQProvider(elementName, namespace)
                            if (provider.isSome()) {
                                iqPacket = provider?.parse(parser, iqData, outerXmlEnvironment)
                            } else {
                                iqPacket = UnparsedIQ(elementName, namespace, parseElement(parser))
                            }
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        if (iqPacket.isNone()) {
            match (iqData.getType()) {
                case IQType.error =>
                    let iqPacket = ErrorIQ.builder(error, iqData).build()
                    return iqPacket
                case IQType.result => iqPacket = EmptyResultIQ()
                case _ => ()
            }
        }
        iqPacket?.setStanzaId(iqData.getStanzaId())
        iqPacket?.setTo(iqData.getTo())
        iqPacket?.setFrom(iqData.getFrom())
        iqPacket?.setType(iqData.getType())
        iqPacket?.setError(error)
        return iqPacket.getOrThrow()
    }

    /**
     * Parse the available SASL mechanisms reported from the server.
     *
     * @param parser the XML parser, positioned at the start of the mechanisms stanza.
     * @return a collection of Stings with the mechanisms included in the mechanisms stanza.
     * @throws IOException if an I/O error occurred.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     */
    public static func parseMechanisms(parser: XmlPullParser): Collection<String> {
        let mechanisms = ArrayList<String>()
        var done = false
        while (!done) {
            let eventType = parser.next()
            if (eventType == XmlPullParserEvent.START_ELEMENT) {
                let elementName = parser.getName()
                if (elementName == "mechanism") {
                    mechanisms.append(parser.nextText())
                }
            } else if (eventType == XmlPullParserEvent.END_ELEMENT) {
                if (parser.getName() == "mechanisms") {
                    done = true
                }
            }
        }
        return mechanisms
    }

    public static func parseDescriptiveTexts(parser: XmlPullParser, descriptiveTexts: ?Map<String, String>): Map<String,
        String> {
        let tempdescriptiveTexts = descriptiveTexts ?? HashMap<String, String>()
        var xmllang = ParserUtils.getXmlLang(parser) ?? ""
        let text = parser.nextText()
        let previousValue = tempdescriptiveTexts.put(xmllang, text)
        if (previousValue.isSome()) {
            throw Exception("AssertionError")
        }
        return tempdescriptiveTexts
    }

    /**
     * Parses stream error packets.
     *
     * @param parser the XML parser.
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return an stream error packet.
     * @throws IOException if an I/O error occurred.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     */
    public static func parseStreamError(parser: XmlPullParser): StreamError {
        return parseStreamError(parser, None)
    }

    public static func parseStreamError(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): StreamError {
        let initialDepth = parser.getDepth()
        let extensions = ArrayList<ExtensionElement>()
        var descriptiveTexts: ?Map<String, String> = None
        var condition: ?StreamErrorCondition = None
        var conditionText: ?String = None
        let streamErrorXmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    let namespace = parser.getNamespace()
                    match (namespace) {
                        case v where v == StreamError.NAMESPACE => match (name) {
                            case "text" => descriptiveTexts = parseDescriptiveTexts(parser, descriptiveTexts)
                            case _ =>
                                condition = StreamErrorCondition.fromString(name)
                                conditionText = parser.nextText()
                                if (conditionText?.size == 0) {
                                    conditionText = None
                                }
                        }
                        case _ => PacketParserUtils.addExtensionElement(extensions, parser, name, namespace,
                            streamErrorXmlEnvironment)
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        return StreamError(condition, conditionText, descriptiveTexts, extensions)
    }

    /**
     * Parses error sub-packets.
     *
     * @param parser the XML parser.
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return an error sub-packet.
     * @throws IOException if an I/O error occurred.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     */
    public static func parseError(parser: XmlPullParser): StanzaError {
        return parseError(parser, None)
    }

    public static func parseError(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): StanzaError {
        let initialDepth = parser.getDepth()
        var descriptiveTexts: ?Map<String, String> = None
        let stanzaErrorXmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)
        let extensions = ArrayList<ExtensionElement>()
        let builder = StanzaError.getBuilder()
        builder.setType(StanzaErrorType.fromString(parser.getAttributeValue("", "type") ?? ""))
        builder.setErrorGenerator(parser.getAttributeValue("", "by"))

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    let namespace = parser.getNamespace()
                    match (namespace) {
                        case v where v == StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE => match (name) {
                            case "text" => descriptiveTexts = parseDescriptiveTexts(parser, descriptiveTexts)
                            case _ =>
                                builder.setCondition(StanzaErrorCondition.fromString(name))
                                let conditionText = parser.nextText()
                                if (conditionText.size != 0) {
                                    builder.setConditionText(conditionText)
                                }
                        }
                        case _ => PacketParserUtils.addExtensionElement(extensions, parser, name, namespace,
                            stanzaErrorXmlEnvironment)
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        builder.setExtensions(extensions).setDescriptiveTexts(descriptiveTexts)
        return builder.build()
    }

    public static func parseExtensionElement(elementName: String, namespace: String, parser: XmlPullParser,
        outerXmlEnvironment: ?XmlEnvironment): ExtensionElement {
        ParserUtils.assertAtStartTag(parser)
        let provider = ProviderManager.getExtensionProvider(elementName, namespace)
        if (let Some(provider) <- provider) {
            return provider.parse(parser, outerXmlEnvironment)
        }
        return StandardExtensionElementProvider.INSTANCE.parse(parser, outerXmlEnvironment)
    }

    public static func parseStartTlsFeature(parser: XmlPullParser): StartTls {
        ParserUtils.assertAtStartTag(parser)
        if (parser.getNamespace() != StartTls.NAMESPACE) {
            throw Exception("AssertionError")
        }
        let initalDepth = parser.getDepth()
        var required = false

        while (true) {
            let event = parser.next()
            match (event) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    match (name) {
                        case "required" => required = true
                        case _ => ()
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initalDepth) {
                    break
                }
                case _ => ()
            }
        }
        ParserUtils.assertAtEndTag(parser)
        return StartTls(required)
    }

    public static func parseSessionFeature(parser: XmlPullParser): SessionFeature {
        ParserUtils.assertAtStartTag(parser)
        let initialDepth = parser.getDepth()
        var optional = false

        while (true) {
            let event = parser.next()
            match (event) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    if (name == SessionFeature.OPTIONAL_ELEMENT) {
                        optional = true
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        return SessionFeature(optional)
    }

    public static func addExtensionElement(stanzaBuilder: StanzaBuilder, parser: XmlPullParser,
        outerXmlEnvironment: ?XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(stanzaBuilder, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    public static func addExtensionElement(stanzaBuilder: StanzaBuilder, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: ?XmlEnvironment): Unit {
        let extensionElement = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
    }

    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(packet, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: ?XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        packet.addExtension(packetExtension)
    }

    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        outerXmlEnvironment: ?XmlEnvironment): Unit {
        addExtensionElement(collection, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        elementName: String, namespace: String, outerXmlEnvironment: ?XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        collection.append(packetExtension)
    }

    public static func parseDescriptiveTexts(
        parser: XmlPullParser,
        descriptiveTexts: Map<String, String>
    ): Map<String, String> {
        var tempdescriptiveTexts = descriptiveTexts
        if (tempdescriptiveTexts.isEmpty()) {
            tempdescriptiveTexts = HashMap<String, String>()
        }
        var xmllang = ParserUtils.getXmlLang(parser) ?? ""
        let text = parser.nextText()
        let previousValue = tempdescriptiveTexts.put(xmllang, text)
        if (previousValue.isSome()) {
            throw Exception("AssertionError")
        }
        return tempdescriptiveTexts
    }

    /**
     * Parses an extension element.
     *
     * @param elementName the XML element name of the extension element.
     * @param namespace the XML namespace of the stanza extension.
     * @param parser the XML parser, positioned at the starting element of the extension.
     * @param outerXmlEnvironment the outer XML environment (optional).
     *
     * @return an extension element.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws IOException if an I/O error occurred.
     * @throws XmppParsingException if the Xmpp parser (provider) encountered invalid input.
     */
    public static func parseExtensionElement(elementName: String, namespace: String, parser: XmlPullParser,
        outerXmlEnvironment: XmlEnvironment): ExtensionElement {
        ParserUtils.assertAtStartTag(parser)
        let provider = ProviderManager.getExtensionProvider(elementName, namespace)
        if (let Some(provider) <- provider) {
            return provider.parse(parser, outerXmlEnvironment)
        }
        // return StandardExtensionElementProvider.INSTANCE.parse(parser, outerXmlEnvironment)
        throw Exception("TODO")
    }

    public static func addExtensionElement(stanzaBuilder: StanzaBuilder, parser: XmlPullParser,
        outerXmlEnvironment: XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(stanzaBuilder, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    public static func addExtensionElement(stanzaBuilder: StanzaBuilder, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: XmlEnvironment): Unit {
        let extensionElement = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
    }

    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, outerXmlEnvironment: XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(packet, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        packet.addExtension(packetExtension)
    }

    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        outerXmlEnvironment: XmlEnvironment): Unit {
        addExtensionElement(collection, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        elementName: String, namespace: String, outerXmlEnvironment: XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        collection.append(packetExtension)
    }
}
