/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.provider

/**
 * 有助于解析数据包的实用程序类。必须共享的任何解析数据包方法
 * 许多客户端之间必须放置在这个实用程序类中。
 */
public class PacketParserUtils {
    private static let LOGGER = getGlobalLogger(("name", "PacketParserUtils"))

    /**  
     * 从给定的字符串获取 XMLPullParser 实例。
     *
     * @param stanza 要解析的 stanzas（数据包）的字符串表示。
     * @return XMLPullParser 实例。
     * @throws XmlPullParserException 如果创建解析器失败。
     * @throws IOException 如果读取输入时发生 I/O 错误。
     */
    public static func getParserFor(stanza: String): XmlPullParser {
        let input = ByteArrayStream()
        input.write(stanza.toArray())
        return getParserFor(input)
    }

    /**  
     * 从输入流获取 XMLPullParser 实例。
     *
     * @param inputStream 输入流。
     * @return XMLPullParser 实例。
     * @throws XmlPullParserException 如果创建解析器失败。
     */
    public static func getParserFor(inputStream: InputStream): XmlPullParser {
        var parser: XmlPullParser = XmppXmlParser.newXmlParser(inputStream)
        ParserUtils.forwardToStartElement(parser)
        return parser
    }

    /**  
     * 解析给定的 stanzas 字符串为 {@link Stanza} 对象。
     *
     * @param stanza XML 格式的 stanzas 字符串。
     * @param <S> 解析的 Stanza 类型。
     * @return 解析后的 Stanza 对象。
     * @throws XmlPullParserException 如果解析失败。
     * @throws XmppParsingException 如果解析期间发生问题。
     * @throws IOException 如果读取输入时发生 I/O 错误。
     */
    public static func parseStanza<S>(stanza: String): S where S <: Stanza {
        return (parseStanza(getParserFor(stanza), XmlEnvironment.EMPTY) as S).getOrThrow()
    }

    /**  
     * 解析 XMLPullParser 中的 Stanza。
     *
     * @param parser XMLPullParser 实例。
     * @param outerXmlEnvironment 包含此 Stanza 的外部 XML 环境。
     * @return 解析得到的 Stanza。
     * @throws XmlPullParserException 如果解析失败。
     * @throws XmppParsingException 如果解析期间发生问题。
     * @throws IOException 如果读取输入时发生 I/O 错误。
     */
    public static func parseStanza(parser: XmlPullParser, outerXmlEnvironment: XmlEnvironment): Stanza {
        ParserUtils.assertAtStartTag(parser)
        let name = parser.getName()
        match (name) {
            case v where v == Message.ELEMENT => return castOrThrow<Message, Stanza>(
                parseMessage(parser, outerXmlEnvironment))
            case v where v == IQ.IQ_ELEMENT => return castOrThrow<IQ, Stanza>(parseIQ(parser, outerXmlEnvironment))
            case v where v == Presence.ELEMENT => return castOrThrow<Presence, Stanza>(
                parsePresence(parser, outerXmlEnvironment))
            case _ => throw IllegalArgumentException("Can only parse message, iq or presence, not ${name}")
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

    /**  
     * 解析给定的 XMLPullParser 中的消息。
     *
     * @param parser XMLPullParser 实例，用于解析消息。
     * @return 解析后的 Message 对象。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     * @throws XmppParsingException 如果解析失败或其他解析问题。
     */
    public static func parseMessage(parser: XmlPullParser): Message {
        return parseMessage(parser, XmlEnvironment.EMPTY)
    }

    /**  
     * 解析给定的 XMLPullParser 中的消息，并考虑外部 XML 环境。
     *
     * @param parser XMLPullParser 实例，用于解析消息。
     * @param outerXmlEnvironment 外部 XML 环境上下文。
     * @return 解析后的 Message 对象。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     * @throws XmppParsingException 如果解析失败或其他解析问题。
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
     * 解析给定元素的文本内容。
     *
     * @param parser XMLPullParser 实例，并处于开始标签位置。
     * @return 元素的文本内容。
     * @throws XmlPullParserException 如果解析过程出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
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
     * 解析指定的 XML 元素，返回其内容。
     *
     * @param parser XMLPullParser 实例，并处于开始标签位置。
     * @return 元素的内容。
     * @throws XmlPullParserException 如果解析过程出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     */
    public static func parseElement(parser: XmlPullParser): String {
        return parseElement(parser, false)
    }

    /**  
     * 解析指定的 XML 元素，返回其内容，可以选择解析完整命名空间。
     *
     * @param parser XMLPullParser 实例，并处于开始标签位置。
     * @param fullNamespaces 是否解析完整命名空间。
     * @return 元素的内容。
     * @throws XmlPullParserException 如果解析过程出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     */
    public static func parseElement(parser: XmlPullParser, fullNamespaces: Bool): String {
        if (parser.getEventType() != XmlPullParserEvent.START_ELEMENT) {
            throw Exception("AssertionError")
        }
        return parseContentDepth(parser, parser.getDepth(), fullNamespaces)
    }

    /**  
     * 解析在指定深度开始的内容。
     *
     * @param parser XMLPullParser 实例，用于解析内容。
     * @param depth 当前深度。
     * @return 解析的内容。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     */
    public static func parseContentDepth(parser: XmlPullParser, depth: Int): String {
        return parseContentDepth(parser, depth, false)
    }

    /**  
     * 解析在指定深度开始的内容，支持完全命名空间的解析选择。
     *
     * @param parser XMLPullParser 实例，用于解析内容。
     * @param depth 当前深度。
     * @param fullNamespaces 是否解析完整命名空间。
     * @return 解析的内容。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
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

    /**  
     * 解析 Presence 数据包。
     *
     * @param parser XMLPullParser 实例，用于解析 Presence 数据包。
     * @return 解析后的 Presence 对象。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他解析问题。
     */
    public static func parsePresence(parser: XmlPullParser): Presence {
        return parsePresence(parser, XmlEnvironment.EMPTY)
    }

    /**  
     * 解析 Presence 数据包，并考虑外部 XML 环境。
     *
     * @param parser XMLPullParser 实例，用于解析 Presence 数据包。
     * @param outerXmlEnvironment 外部 XML 环境上下文。
     * @return 解析后的 Presence 对象。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他解析问题。
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
     * 解析 IQ 数据包。
     *
     * @param parser XMLPullParser 实例，用于解析 IQ 数据包。
     * @return 解析后的 IQ 对象。
     * @throws Exception 如果解析过程中出现错误。
     */
    public static func parseIQ(parser: XmlPullParser): IQ {
        return parseIQ(parser, None)
    }

    /**  
     * 解析 IQ 数据的详细信息。
     *
     * @param parser XMLPullParser 实例，用于解析 IQ 数据。
     * @return 解析后的 IqData 对象。
     * @throws XmppStringprepException 如果字符串预处理失败（如 JID 格式错误）。
     */
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

    /**  
     * 解析 IQ 数据包。
     *
     * @param parser XMLPullParser 实例，用于解析 IQ 数据包。
     * @param outerXmlEnvironment 外部 XML 环境上下文。
     * @return 解析后的 IQ 对象。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws XmppStringprepException 如果字符串预处理失败（如 JID 格式错误）。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他解析问题。
     */
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
     * 解析 SASL 机制。
     *
     * @param parser XMLPullParser 实例，用于解析 SASL 机制。
     * @return 解析后的机制列表。
     * @throws XmlPullParserException 如果解析过程中出现 XML 解析错误。
     * @throws IOException 如果在解析过程中出现 I/O 异常。
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

    /**  
     * 解析描述性文本。
     *
     * @param parser 用于解析的 XMLPullParser 实例。
     * @param descriptiveTexts 现有的描述性文本映射，如果为空，则创建一个新的映射。
     * @return 解析后的描述性文本映射。
     * @throws XmlPullParserException 如果发生 XML 解析异常。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     */
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
     * 解析流错误。
     *
     * @param parser 用于解析的 XMLPullParser 实例。
     * @return 解析后的 StreamError 对象。
     * @throws XmlPullParserException 如果发生 XML 解析异常。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他解析问题。
     */
    public static func parseStreamError(parser: XmlPullParser): StreamError {
        return parseStreamError(parser, None)
    }

    /**  
     * 解析带有外部 XML 环境的流错误。
     *
     * @param parser 用于解析的 XMLPullParser 实例。
     * @param outerXmlEnvironment 外部 XML 环境上下文。
     * @return 解析后的 StreamError 对象。
     * @throws XmlPullParserException 如果发生 XML 解析异常。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他解析问题。
     */
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
     * 解析 XMPP 数据包中的错误。
     *
     * @param parser 用于解析错误的 XMLPullParser 实例。
     * @return 解析后的 StanzaError 对象。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他问题。
     */
    public static func parseError(parser: XmlPullParser): StanzaError {
        return parseError(parser, None)
    }

    /**  
     * 解析 XMPP 数据包中的错误，并考虑外部 XML 环境。
     *
     * @param parser 用于解析错误的 XMLPullParser 实例。
     * @param outerXmlEnvironment 外部 XML 环境信息。
     * @return 解析后的 StanzaError 对象。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他问题。
     */
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

    /**  
     * 解析扩展元素。
     *
     * @param elementName 元素名称。
     * @param namespace 命名空间。
     * @param parser 用于解析扩展元素的 XMLPullParser 实例。
     * @param outerXmlEnvironment 外部 XML 环境。
     * @return 解析后的 ExtensionElement 对象。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他问题。
     */
    public static func parseExtensionElement(elementName: String, namespace: String, parser: XmlPullParser,
        outerXmlEnvironment: ?XmlEnvironment): ExtensionElement {
        ParserUtils.assertAtStartTag(parser)
        let provider = ProviderManager.getExtensionProvider(elementName, namespace)
        if (let Some(provider) <- provider) {
            return provider.parse(parser, outerXmlEnvironment)
        }
        return StandardExtensionElementProvider.INSTANCE.parse(parser, outerXmlEnvironment)
    }

    /**  
     * 解析 StartTLS 特性。
     *
     * @param parser 用于解析 StartTLS 特性的 XMLPullParser 实例。
     * @return 解析后的 StartTls 对象，指示是否为必需。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     */
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

    /**  
     * 解析会话特性。
     *
     * @param parser 用于解析会话特性的 XMLPullParser 实例。
     * @return 解析后的 Session.Feature 对象，指示是否为可选。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     */
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

    /**  
     * 向 StanzaBuilder 添加扩展元素。
     *
     * @param stanzaBuilder 被添加扩展的 StanzaBuilder 实例。
     * @param parser 用于解析扩展元素的 XMLPullParser 实例。
     * @param outerXmlEnvironment 外部 XML 环境。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他问题。
     */
    public static func addExtensionElement(stanzaBuilder: StanzaBuilder, parser: XmlPullParser,
        outerXmlEnvironment: ?XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(stanzaBuilder, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    /**  
     * 向给定的 StanzaBuilder 添加扩展元素。
     *
     * @param _ 要添加扩展的 StanzaBuilder 实例
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(_: StanzaBuilder, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: ?XmlEnvironment): Unit {
        let extensionElement = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
    }

    /**  
     * 向给定的数据包添加扩展元素，自动提取元素名称和命名空间。
     *
     * @param packet 要添加扩展的 Stanza 实例
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(packet, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    /**  
     * 向给定的数据包添加扩展元素，指定元素名称和命名空间。
     *
     * @param packet 要添加扩展的 Stanza 实例
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: ?XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        packet.addExtension(packetExtension)
    }

    /**  
     * 向给定的集合添加扩展元素，自动提取元素名称和命名空间。
     *
     * @param collection 要添加扩展的集合
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        outerXmlEnvironment: ?XmlEnvironment): Unit {
        addExtensionElement(collection, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    /**  
     * 向给定的集合添加扩展元素，指定元素名称和命名空间。
     *
     * @param collection 要添加扩展的集合
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        elementName: String, namespace: String, outerXmlEnvironment: ?XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        collection.append(packetExtension)
    }

    /**  
     * 解析扩展元素。
     *
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param outerXmlEnvironment 外部 XML 环境
     * @return 解析后的 ExtensionElement 对象
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
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
     * 解析扩展元素。
     *
     * @param elementName 元素名称。
     * @param namespace 命名空间。
     * @param parser 用于解析扩展元素的 XMLPullParser 实例。
     * @param outerXmlEnvironment 外部 XML 环境。
     * @return 解析后的 ExtensionElement 对象。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他问题。
     */
    public static func parseExtensionElement(elementName: String, namespace: String, parser: XmlPullParser,
        outerXmlEnvironment: XmlEnvironment): ExtensionElement {
        ParserUtils.assertAtStartTag(parser)
        let provider = ProviderManager.getExtensionProvider(elementName, namespace)
        if (let Some(provider) <- provider) {
            return provider.parse(parser, outerXmlEnvironment)
        }
        return StandardExtensionElementProvider.INSTANCE.parse(parser, outerXmlEnvironment)
    }

    /**  
     * 向 StanzaBuilder 添加扩展元素。
     *
     * @param stanzaBuilder 被添加扩展的 StanzaBuilder 实例。
     * @param parser 用于解析扩展元素的 XMLPullParser 实例。
     * @param outerXmlEnvironment 外部 XML 环境。
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析错误。
     * @throws IOException 如果在解析过程中发生 I/O 异常。
     * @throws XmppParsingException 如果解析失败或遇到其他问题。
     */
    public static func addExtensionElement(stanzaBuilder: StanzaBuilder, parser: XmlPullParser,
        outerXmlEnvironment: XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(stanzaBuilder, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    /**  
     * 向给定的 StanzaBuilder 添加扩展元素。
     *
     * @param _ 要添加扩展的 StanzaBuilder 实例
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(_: StanzaBuilder, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: XmlEnvironment): Unit {
        let extensionElement = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
    }

    /**  
     * 向给定的数据包添加扩展元素，自动提取元素名称和命名空间。
     *
     * @param packet 要添加扩展的 Stanza 实例
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, outerXmlEnvironment: XmlEnvironment): Unit {
        ParserUtils.assertAtStartTag(parser)
        addExtensionElement(packet, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    /**  
     * 向给定的数据包添加扩展元素，指定元素名称和命名空间。
     *
     * @param packet 要添加扩展的 Stanza 实例
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(packet: Stanza, parser: XmlPullParser, elementName: String,
        namespace: String, outerXmlEnvironment: XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        packet.addExtension(packetExtension)
    }

    /**  
     * 向给定的集合添加扩展元素，自动提取元素名称和命名空间。
     *
     * @param collection 要添加扩展的集合
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        outerXmlEnvironment: XmlEnvironment): Unit {
        addExtensionElement(collection, parser, parser.getName(), parser.getNamespace(), outerXmlEnvironment)
    }

    /**  
     * 向给定的集合添加扩展元素，指定元素名称和命名空间。
     *
     * @param collection 要添加扩展的集合
     * @param parser 用于解析扩展元素的 XMLPullParser 实例
     * @param elementName XML 元素的名称
     * @param namespace XML 元素的命名空间
     * @param outerXmlEnvironment 外部 XML 环境
     * @throws XmlPullParserException 如果解析过程发生 XML 解析错误
     * @throws IOException 如果在解析过程中发生 I/O 异常
     * @throws XmppParsingException 如果解析失败或遇到其他问题
     */
    public static func addExtensionElement(collection: ArrayList<ExtensionElement>, parser: XmlPullParser,
        elementName: String, namespace: String, outerXmlEnvironment: XmlEnvironment): Unit {
        let packetExtension = parseExtensionElement(elementName, namespace, parser, outerXmlEnvironment)
        collection.append(packetExtension)
    }
}
