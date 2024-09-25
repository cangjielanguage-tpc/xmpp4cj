/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class ParserUtils {
    public static let JID = "jid"

    public static func assertAtStartTag(parser: XmlPullParser, name: String): Unit {
        assertAtStartTag(parser)
        if (name != parser.getName()) {
            throw Exception("AssertionError")
        }
    }

    public static func assertAtEndTag(parser: XmlPullParser): Unit {
        if (parser.getEventType() != XmlPullParserEvent.END_ELEMENT) {
            throw Exception("AssertionError")
        }
    }

    // throws XmlPullParserException, IOException 
    public static func forwardToStartElement(parser: XmlPullParser): Unit {
        // Wind the parser forward to the first start tag
        var event: XmlPullParserEvent = parser.getEventType()
        while (event != XmlPullParserEvent.START_ELEMENT) {
            if (event == XmlPullParserEvent.END_DOCUMENT) {
                throw IllegalArgumentException("Document contains no start tag")
            }
            event = parser.next()
        }
    }

    // throws XmlPullParserException
    public static func forwardToEndTagOfDepth(parser: XmlPullParser, depth: Int): Unit {
        var event = parser.getEventType()
        while (!(event == XmlPullParserEvent.END_ELEMENT && parser.getDepth() == depth)) {
            assert(event != XmlPullParserEvent.END_DOCUMENT)
            event = parser.next()
        }
    }

    public static func getJidAttribute(parser: XmlPullParser): ?Jid {
        return getJidAttribute(parser, JID)
    }

    public static func getJidAttribute(parser: XmlPullParser, name: String): ?Jid {
        let jidString = if (let Some(v) <- parser.getAttributeValue("", name)) {
            v
        } else {
            return None
        }
        return JidCreate.froms(jidString)
    }

    public static func getBareJidAttribute(parser: XmlPullParser): ?EntityBareJid {
        return getBareJidAttribute(parser, JID)
    }

    public static func getBareJidAttribute(parser: XmlPullParser, name: String): ?EntityBareJid {
        let jidString = if (let Some(v) <- parser.getAttributeValue("", name)) {
            v
        } else {
            return None
        }
        return JidCreate.entityBareFrom(jidString)
    }

    public static func getFullJidAttribute(parser: XmlPullParser): ?EntityFullJid {
        return getFullJidAttribute(parser, JID)
    }

    public static func getFullJidAttribute(parser: XmlPullParser, name: String): ?EntityFullJid {
        let jidString = parser.getAttributeValue("", name) ?? return None
        return JidCreate.entityFullFrom(jidString)
    }

    public static func getEntityJidAttribute(parser: XmlPullParser, name: String): ?EntityJid {
        let jidString = parser.getAttributeValue("", name) ?? return None
        let jid = JidCreate.froms(jidString)
        if (!jid.hasLocalpart()) {
            return None
        }
        let fullJid = jid.asEntityFullJidIfPossible()
        if (let Some(v) <- fullJid) {
            return v
        }
        let bareJid = jid.asEntityBareJidIfPossible()
        return bareJid ?? None
    }

    public static func getResourcepartAttribute(parser: XmlPullParser, name: String): ?Resourcepart {
        let resourcepartString = parser.getAttributeValue("", name) ?? return None
        return Resourcepart.froms(resourcepartString)
    }

    public static func parseXmlBool(booleanString: String): Bool {
        match (booleanString) {
            case "true" | "1" => return true
            case "false" | "0" => return false
            case _ => throw IllegalArgumentException((booleanString) + " is not a valid boolean string")
        }
    }

    public static func getBooleanAttribute(parser: XmlPullParser, name: String): ?Bool {
        var valueString = parser.getAttributeValue("", name) ?? return None
        valueString = valueString.toAsciiLower()
        return parseXmlBool(valueString)
    }

    public static func getBooleanAttribute(parser: XmlPullParser, name: String, defaultValue: Bool): Bool {
        let bool = getBooleanAttribute(parser, name)
        if (let Some(bool) <- bool) {
            return bool
        } else {
            return defaultValue
        }
    }

    public static func getByteAttributeFromNextText(parser: XmlPullParser): UInt8 {
        let nextText = parser.nextText()
        return UInt8.parse(nextText)
    }

    public static func getIntegerAttributeOrThrow(parser: XmlPullParser, name: String, throwMessage: String): Int {
        let res = getIntegerAttribute(parser, name)
        return res.getOrThrow({=> IOException(throwMessage)})
    }

    public static func getIntegerAttribute(parser: XmlPullParser, name: String): ?Int {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Int.parse(valueString)
    }

    public static func getIntegerAttribute(parser: XmlPullParser, name: String, defaultValue: Int): Int {
        let integer = getIntegerAttribute(parser, name)
        if (let Some(integer) <- integer) {
            return integer
        } else {
            return defaultValue
        }
    }

    public static func getUInt16Attribute(parser: XmlPullParser, name: String): ?UInt16 {
        let integer = parser.getAttributeValue("", name) ?? return None
        return UInt16.parse(integer)
    }

    public static func getRequiredUInt16Attribute(parser: XmlPullParser, name: String): UInt16 {
        let uint16 = getUInt16Attribute(parser, name)
        return uint16.getOrThrow({=> XmppRequiredAttributeMissingException(name)})
    }

    public static func getIntegerFromNextText(parser: XmlPullParser): Int {
        let intString = parser.nextText()
        return Int.parse(intString)
    }

    public static func getLongAttribute(parser: XmlPullParser, name: String): ?Int64 {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Int64.parse(valueString)
    }

    public static func getLongAttribute(parser: XmlPullParser, name: String, defaultValue: Int64): Int64 {
        let l = getLongAttribute(parser, name)
        l ?? defaultValue
    }

    public static func getUIntAttribute(parser: XmlPullParser, name: String): ?UInt64 {
        let l = getLongAttribute(parser, name) ?? return None
        return UInt64(l)
    }

    public static func getDoubleFromNextText(parser: XmlPullParser): Float64 {
        let doubleString = parser.nextText()
        return Float64.parse(doubleString)
    }

    public static func getDoubleAttribute(parser: XmlPullParser, name: String): ?Float64 {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Float64.parse(valueString)
    }

    public static func getDoubleAttribute(parser: XmlPullParser, name: String, defaultValue: Int64): Float64 {
        let d = getDoubleAttribute(parser, name)
        return d ?? Float64(defaultValue)
    }

    public static func getShortAttribute(parser: XmlPullParser, name: String): ?Int16 {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Int16.parse(valueString)
    }

    public static func getShortAttribute(parser: XmlPullParser, name: String, defaultValue: Int16): Int16 {
        let s = getShortAttribute(parser, name)
        return s ?? defaultValue
    }

    public static func getDateFromOptionalXep82String(dateString: ?String): ?DateTime {
        let str = dateString ?? return None
        return getDateFromXep82String(str)
    }

    public static func getDateFromXep82String(dateString: String): DateTime {
        try {
            return XmppDateTime.parseXEP0082Date(dateString)
        } catch (e: TimeParseException) {
            throw XmppTextParseException(e)
        }
    }

    public static func getDateFromString(dateString: String): DateTime {
        try {
            return XmppDateTime.parseDate(dateString)
        } catch (e: TimeParseException) {
            throw XmppTextParseException(e)
        }
    }

    public static func getDateFromNextText(parser: XmlPullParser): DateTime {
        let dateString = parser.nextText()
        return getDateFromString(dateString)
    }

    public static func getUriFromNextText(parser: XmlPullParser): URL {
        let uriString = parser.nextText()
        try {
            return URL.parse(uriString)
        } catch (e: UrlSyntaxException) {
            throw XmppUriSyntaxParsingException(e)
        }
    }

    public static func getRequiredAttribute(parser: XmlPullParser, name: String): String {
        let value = parser.getAttributeValue("", name)
        if (StringUtils.isNullOrEmpty(value)) {
            throw IOException("Attribute ${name} is null or empty (${value})")
        }
        return value.getOrThrow()
    }

    public static func getRequiredNextText(parser: XmlPullParser): String {
        let text = parser.nextText()
        if (StringUtils.isNullOrEmpty(text)) {
            throw IOException("Next text is null or empty (" + (text) + r')'.toString())
        }
        return text
    }

    public static func getXmlLang(parser: XmlPullParser, xmlEnvironment: XmlEnvironment): ?String {
        let currentXmlLang = getXmlLang(parser)
        if (let Some(v) <- currentXmlLang) {
            return v
        }
        return xmlEnvironment.getEffectiveLanguage()
    }

    public static func getInternetAddressIngoringZoneIdAttribute(parser: XmlPullParser, attribute: String): ?IPAddress {
        let inetAddressString = parser.getAttributeValue(attribute) ?? return None
        return IPAddress.tryParse(inetAddressString)
    }

    public static func getXmlLang(parser: XmlPullParser): ?String {
        return parser.getAttributeValue(W3_XML_NAMESPACE, "lang")
    }

    // throws XmlPullParserException
    public static func assertAtStartTag(parser: XmlPullParser): Unit {
        assert(parser.getEventType() == XmlPullParserEvent.START_ELEMENT)
    }
}
