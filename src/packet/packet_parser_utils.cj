/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Utility class that helps to parse packets. Any parsing packets method that must be shared
 * between many clients must be placed in this utility class.
 */
public class PacketParserUtils {
    // throws XmppStringprepException
    public static func parseIqData(parser: XmlPullParser): IqData {
        let id: ?String = parser.getAttributeValue("", "id")
        let iqData: IqData = StanzaBuilder.buildIqData(id)

        let to = ParserUtils.getJidAttribute(parser, "to")
        iqData.to(to)

        let froms = ParserUtils.getJidAttribute(parser, "from")
        iqData.froms(froms)

        let typeString: String = parser.getAttributeValue("", "type") ?? ""
        let typ: IQType = IQType.fromString(typeString)
        iqData.ofType(typ)

        return iqData
    }

    /**
     * Parses stream error packets.
     *
     * @param parser the XML parser.
     * @param outerXmlEnvironment the outer XML environment (optional).
     * @return an stream error packet.
     * @throws IOException if an I/O error occurred.
     * @throws XmlPullParserException if an error in the XML parser occurred.
     * @throws SmackParsingException if the Smack parser (provider) encountered invalid input.
     */
    public static func parseStreamError(parser: XmlPullParser): StreamError {
        return parseStreamError(parser, None)
    }

    public static func parseStreamError(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): StreamError {
        let initialDepth = parser.getDepth()
        let extensions = ArrayList<ExtensionElement>()
        var descriptiveTexts: Map<String, String> = Collections.EMPTY_STRING_MAP
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
                        case "urn:ietf:params:xml:ns:xmpp-streams" => match (name) {
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
     * @throws SmackParsingException if the Smack parser (provider) encountered invalid input.
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
