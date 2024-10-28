/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**  
 * {@code ParserUtils} 提供了一些实用工具方法，用于处理和解析 XML 数据，特别是在 XMPP 环境中。
 * <p>
 * 此类包含多种方法，用于解析 XML 属性及其中的内容，以便处理 XMPP 相关的 JID、日期、数量等数据类型。
 * </p>
 */
public class ParserUtils {
    /**
     * 常量 JID，用于表示 XML 属性中的 JID 属性名称。
     */
    public static let JID = "jid"

    /**  
     * 检查解析器当前位置是否在起始标签上。
     *
     * @param parser XML 解析器实例。
     * @throws XmlPullParserException 如果当前事件类型不是起始标签。
     */
    public static func assertAtStartTag(parser: XmlPullParser): Unit {
        assert(parser.getEventType() == XmlPullParserEvent.START_ELEMENT)
    }

    /**  
     * 检查解析器当前位置是否在起始标签上。
     *
     * @param parser XML 解析器实例。
     * @throws XmlPullParserException 如果当前事件类型不是起始标签。
     */
    public static func assertAtStartTag(parser: XmlPullParser, name: String): Unit {
        assertAtStartTag(parser)
        if (name != parser.getName()) {
            throw Exception("AssertionError")
        }
    }

    /**  
     * 检查解析器当前位置是否在结束标签上。
     *
     * @param parser XML 解析器实例。
     * @throws XmlPullParserException 如果当前事件类型不是结束标签。
     */
    public static func assertAtEndTag(parser: XmlPullParser): Unit {
        if (parser.getEventType() != XmlPullParserEvent.END_ELEMENT) {
            throw Exception("AssertionError")
        }
    }

    /**  
     * 将解析器向前移动到第一个起始标签。
     *
     * @param parser XML 解析器实例。
     * @throws XmlPullParserException 如果出现 XML 解析错误。
     * @throws IOException 如果在读取时发生 I/O 错误。
     */
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

    /**  
     * 将解析器向前移动到指定深度的结束标签。
     *
     * @param parser XML 解析器实例。
     * @param depth 指定的标签深度。
     * @throws XmlPullParserException 如果出现 XML 解析错误。
     * @throws IOException 如果在读取时发生 I/O 错误。
     */
    public static func forwardToEndTagOfDepth(parser: XmlPullParser, depth: Int): Unit {
        var event = parser.getEventType()
        while (!(event == XmlPullParserEvent.END_ELEMENT && parser.getDepth() == depth)) {
            assert(event != XmlPullParserEvent.END_DOCUMENT)
            event = parser.next()
        }
    }

    /**  
     * 获取解析器的 JID 属性值。
     *
     * @param parser XML 解析器实例。
     * @return 解析出的 JID，或 {@code null} 如果未设置。
     * @throws XmppStringprepException 如果 JID 格式不正确。
     */
    public static func getJidAttribute(parser: XmlPullParser): ?Jid {
        return getJidAttribute(parser, JID)
    }

    /**  
     * 获取指定名称的 JID 属性值。
     *
     * @param parser XML 解析器实例。
     * @param name 属性名称。
     * @return 了解的 JID，或 {@code null} 如果未设置。
     * @throws XmppStringprepException 如果 JID 格式不正确。
     */
    public static func getJidAttribute(parser: XmlPullParser, name: String): ?Jid {
        let jidString = if (let Some(v) <- parser.getAttributeValue("", name)) {
            v
        } else {
            return None
        }
        return JidCreate.froms(jidString)
    }

    /**  
     * 获取解析器的裸 JID 属性值。
     *
     * @param parser XML 解析器实例。
     * @return 解析出的 EntityBareJid，
     */
    public static func getBareJidAttribute(parser: XmlPullParser): ?EntityBareJid {
        return getBareJidAttribute(parser, JID)
    }

    /**  
     * 从 XML 解析器中获取指定名称的 EntityBareJid 属性。
     *
     * @param parser XML 解析器实例
     * @param name 属性名称
     * @return 解析出的 EntityBareJid 对象，如果属性不存在则返回 null
     * @throws XmppStringprepException 如果 JID 格式不正确
     */
    public static func getBareJidAttribute(parser: XmlPullParser, name: String): ?EntityBareJid {
        let jidString = if (let Some(v) <- parser.getAttributeValue("", name)) {
            v
        } else {
            return None
        }
        return JidCreate.entityBareFrom(jidString)
    }

    /**  
     * 从 XML 解析器中获取 JID 的完整地址。
     *
     * @param parser XML 解析器实例
     * @return 解析出的 EntityFullJid 对象，如果属性不存在则返回 null
     * @throws XmppStringprepException 如果 JID 格式不正确
     */
    public static func getFullJidAttribute(parser: XmlPullParser): ?EntityFullJid {
        return getFullJidAttribute(parser, JID)
    }

    /**  
     * 从 XML 解析器中获取指定名称的完整 JID 属性。
     *
     * @param parser XML 解析器实例
     * @param name 属性名称
     * @return 解析出的 EntityFullJid 对象，如果属性不存在则返回 null
     * @throws XmppStringprepException 如果 JID 格式不正确
     */
    public static func getFullJidAttribute(parser: XmlPullParser, name: String): ?EntityFullJid {
        let jidString = parser.getAttributeValue("", name) ?? return None
        return JidCreate.entityFullFrom(jidString)
    }

    /**  
     * 从 XML 解析器中获取指定名称的 JID 属性。
     *
     * @param parser XML 解析器实例
     * @param name 属性名称
     * @return 解析出的 EntityJid 对象，如果属性不存在则返回 null
     * @throws XmppStringprepException 如果 JID 格式不正确
     */
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

    /**  
     * 从 XML 解析器中获取指定名称的 Resourcepart 属性。
     *
     * @param parser XML 解析器实例
     * @param name 属性名称
     * @return 解析出的 Resourcepart 对象，如果属性不存在则返回 null
     * @throws XmppStringprepException 如果 Resourcepart 格式不正确
     */
    public static func getResourcepartAttribute(parser: XmlPullParser, name: String): ?Resourcepart {
        let resourcepartString = parser.getAttributeValue("", name) ?? return None
        return Resourcepart.froms(resourcepartString)
    }

    /**  
     * 解析代表布尔值的字符串。
     *
     * @param booleanString 布尔字符串，应该是 "true", "false", "1", 或 "0"
     * @return 解析后的布尔值
     * @throws IllegalArgumentException 如果字符串不是有效的布尔值
     */
    public static func parseXmlBool(booleanString: String): Bool {
        match (booleanString) {
            case "true" | "1" => return true
            case "false" | "0" => return false
            case _ => throw IllegalArgumentException("${booleanString} is not a valid boolean string")
        }
    }

    /**  
     * 获取指定名称的布尔属性值。
     *
     * @param parser XML 解析器实例
     * @param name 属性名称
     * @return 解析出的布尔值，如果属性不存在则返回 null
     */
    public static func getBooleanAttribute(parser: XmlPullParser, name: String): ?Bool {
        var valueString = parser.getAttributeValue("", name) ?? return None
        valueString = valueString.toAsciiLower()
        return parseXmlBool(valueString)
    }

    /**  
     * 从 XML 解析器中获取指定名称的布尔值属性。
     *
     * @param parser      XML 解析器实例
     * @param name        属性名称
     * @param defaultValue 默认值，如果属性不存在时返回
     * @return 解析出的布尔值，如果属性不存在则返回默认值
     */
    public static func getBooleanAttribute(parser: XmlPullParser, name: String, defaultValue: Bool): Bool {
        let bool = getBooleanAttribute(parser, name)
        if (let Some(bool) <- bool) {
            return bool
        } else {
            return defaultValue
        }
    }

    /**  
     * 从 XML 解析器中获取下一个文本并将其解析为 Byte。
     *
     * @param parser XML 解析器实例
     * @return 解析出的 Byte 对象，如果文本不存在则返回 null
     * @throws IOException            如果发生 I/O 错误
     * @throws XmlPullParserException 如果 XML 解析错误
     */
    public static func getByteAttributeFromNextText(parser: XmlPullParser): UInt8 {
        let nextText = parser.nextText()
        return UInt8.parse(nextText)
    }

    /**  
     * 从 XML 解析器中获取指定名称的整数属性，如果未找到则抛出异常。
     *
     * @param parser      XML 解析器实例
     * @param name        属性名称
     * @param throwMessage 当属性未找到时抛出的异常信息
     * @return 解析出的整数值
     * @throws IOException 如果未找到属性
     */
    public static func getIntegerAttributeOrThrow(parser: XmlPullParser, name: String, throwMessage: String): Int {
        let res = getIntegerAttribute(parser, name)
        return res.getOrThrow({=> IOException(throwMessage)})
    }

    /**  
     * 获取指定名称的整数属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的整数值，如果属性不存在则返回 null
     */
    public static func getIntegerAttribute(parser: XmlPullParser, name: String): ?Int {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Int.parse(valueString)
    }

    /**  
     * 从 XML 解析器中获取指定名称的整数属性值，若未找到则返回默认值。
     *
     * @param parser      XML 解析器实例
     * @param name        属性名称
     * @param defaultValue 默认值
     * @return 解析出的整数值，如果属性不存在则返回默认值
     */
    public static func getIntegerAttribute(parser: XmlPullParser, name: String, defaultValue: Int): Int {
        let integer = getIntegerAttribute(parser, name)
        if (let Some(integer) <- integer) {
            return integer
        } else {
            return defaultValue
        }
    }

    /**  
     * 获取指定名称的无符号 16 位整数属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的无符号 16 位整数，如果属性不存在则返回 null
     */
    public static func getUInt16Attribute(parser: XmlPullParser, name: String): ?UInt16 {
        let integer = parser.getAttributeValue("", name) ?? return None
        return UInt16.parse(integer)
    }

    /**  
     * 获取指定名称的必需的无符号 16 位整数属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的无符号 16 位整数
     * @throws RequiredAttributeMissingException 如果属性缺失
     */
    public static func getRequiredUInt16Attribute(parser: XmlPullParser, name: String): UInt16 {
        let uint16 = getUInt16Attribute(parser, name)
        return uint16.getOrThrow({=> XmppRequiredAttributeMissingException(name)})
    }

    /**  
     * 从 XML 解析器中获取下一个文本并将其解析为整数。
     *
     * @param parser XML 解析器实例
     * @return 解析出的整数值
     * @throws XmlPullParserException 如果 XML 解析错误
     * @throws IOException            如果发生 I/O 错误
     */
    public static func getIntegerFromNextText(parser: XmlPullParser): Int {
        let intString = parser.nextText()
        return Int.parse(intString)
    }

    /**  
     * 获取指定名称的长整型属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的长整型值，如果属性不存在则返回 null
     */
    public static func getLongAttribute(parser: XmlPullParser, name: String): ?Int64 {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Int64.parse(valueString)
    }

    /**  
     * 获取指定名称的长整型属性值，若未找到则返回默认值。
     *
     * @param parser      XML 解析器实例
     * @param name        属性名称
     * @param defaultValue 默认值
     * @return 解析出的长整型值，如果属性不存在则返回默认值
     */
    public static func getLongAttribute(parser: XmlPullParser, name: String, defaultValue: Int64): Int64 {
        let l = getLongAttribute(parser, name)
        l ?? defaultValue
    }

    /**  
     * 获取指定名称的无符号 32 位整数属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的无符号 32 位整数，如果属性不存在则返回 null
     */
    public static func getUIntAttribute(parser: XmlPullParser, name: String): ?UInt64 {
        let l = getLongAttribute(parser, name) ?? return None
        return UInt64(l)
    }

    /**  
     * 从 XML 解析器中获取下一个文本并将其解析为 double 类型。
     *
     * @param parser XML 解析器实例
     * @return 解析出的 double 值
     * @throws XmlPullParserException 如果 XML 解析错误
     * @throws IOException            如果发生 I/O 错误
     */
    public static func getDoubleFromNextText(parser: XmlPullParser): Float64 {
        let doubleString = parser.nextText()
        return Float64.parse(doubleString)
    }

    /**  
     * 从 XML 解析器中获取指定名称的双精度浮点数属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的双精度浮点数值，如果属性不存在则返回 null
     */
    public static func getDoubleAttribute(parser: XmlPullParser, name: String): ?Float64 {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Float64.parse(valueString)
    }

    /**  
     * 从 XML 解析器中获取指定名称的双精度浮点数属性值，如果未找到则返回默认值。
     *
     * @param parser      XML 解析器实例
     * @param name        属性名称
     * @param defaultValue 默认值
     * @return 解析出的双精度浮点数值，如果属性不存在则返回默认值
     */
    public static func getDoubleAttribute(parser: XmlPullParser, name: String, defaultValue: Int64): Float64 {
        let d = getDoubleAttribute(parser, name)
        return d ?? Float64(defaultValue)
    }

    /**  
     * 从 XML 解析器中获取指定名称的短整型属性值。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的短整型值，如果属性不存在则返回 null
     */
    public static func getShortAttribute(parser: XmlPullParser, name: String): ?Int16 {
        let valueString = parser.getAttributeValue("", name) ?? return None
        return Int16.parse(valueString)
    }

    /**  
     * 从 XML 解析器中获取指定名称的短整型属性值，如果未找到则返回默认值。
     *
     * @param parser      XML 解析器实例
     * @param name        属性名称
     * @param defaultValue 默认值
     * @return 解析出的短整型值，如果属性不存在则返回默认值
     */
    public static func getShortAttribute(parser: XmlPullParser, name: String, defaultValue: Int16): Int16 {
        let s = getShortAttribute(parser, name)
        return s ?? defaultValue
    }

    /**  
     * 从 XEP-0082 格式的字符串中获取日期，如果字符串为 null，则返回 null。
     *
     * @param dateString 日期字符串
     * @return 解析得到的日期对象，如果输入为 null 则返回 null
     * @throws XmppTextParseException 如果日期字符串解析失败
     */
    public static func getDateFromOptionalXep82String(dateString: ?String): ?DateTime {
        let str = dateString ?? return None
        return getDateFromXep82String(str)
    }

    /**  
     * 从 XEP-0082 格式的字符串中获取日期。
     *
     * @param dateString 日期字符串
     * @return 解析得到的日期对象
     * @throws XmppTextParseException 如果日期字符串解析失败
     */
    public static func getDateFromXep82String(dateString: String): DateTime {
        try {
            return XmppDateTime.parseXEP0082Date(dateString)
        } catch (e: TimeParseException) {
            throw XmppTextParseException(e)
        }
    }

    /**  
     * 从标准日期字符串中获取日期。
     *
     * @param dateString 日期字符串
     * @return 解析得到的日期对象
     * @throws XmppTextParseException 如果日期字符串解析失败
     */
    public static func getDateFromString(dateString: String): DateTime {
        try {
            return XmppDateTime.parseDate(dateString)
        } catch (e: TimeParseException) {
            throw XmppTextParseException(e)
        }
    }

    /**  
     * 从 XML 解析器中获取下一个文本并将其解析为日期。
     *
     * @param parser XML 解析器实例
     * @return 解析得到的日期对象
     * @throws XmlPullParserException 如果 XML 解析错误
     * @throws IOException            如果发生 I/O 错误
     * @throws XmppTextParseException 如果日期字符串解析失败
     */
    public static func getDateFromNextText(parser: XmlPullParser): DateTime {
        let dateString = parser.nextText()
        return getDateFromString(dateString)
    }

    /**  
     * 从 XML 解析器中获取下一个文本并将其解析为 URI。
     *
     * @param parser XML 解析器实例
     * @return 解析得到的 URI 对象
     * @throws XmlPullParserException           如果 XML 解析错误
     * @throws IOException                      如果发生 I/O 错误
     * @throws XmppTextParseException   如果 URI 语法错误
     */
    public static func getUriFromNextText(parser: XmlPullParser): URL {
        let uriString = parser.nextText()
        try {
            return URL.parse(uriString)
        } catch (e: UrlSyntaxException) {
            throw XmppUriSyntaxParsingException(e)
        }
    }

    /**  
     * 获取 XML 解析器中的必需属性值。如果属性不存在或为空则抛出异常。
     *
     * @param parser XML 解析器实例
     * @param name   属性名称
     * @return 解析出的属性值
     * @throws IOException 如果属性缺失或为空
     */
    public static func getRequiredAttribute(parser: XmlPullParser, name: String): String {
        let value = parser.getAttributeValue("", name)
        if (StringUtils.isNullOrEmpty(value)) {
            throw IOException("Attribute ${name} is null or empty (${value})")
        }
        return value.getOrThrow()
    }

    /**  
     * 从 XML 解析器中获取下一个文本并返回该文本。如果文本为空，则抛出异常。
     *
     * @param parser XML 解析器实例
     * @return 解析出的文本
     * @throws XmlPullParserException 如果 XML 解析错误
     * @throws IOException            如果发生 I/O 错误
     */
    public static func getRequiredNextText(parser: XmlPullParser): String {
        let text = parser.nextText()
        if (StringUtils.isNullOrEmpty(text)) {
            throw IOException("Next text is null or empty (${text})")
        }
        return text
    }

    /**  
     * 获取当前 XML 语言属性的值，若未找到则返回 XML 环境中定义的有效语言。
     *
     * @param parser XML 解析器实例
     * @param xmlEnvironment XML 环境实例
     * @return 当前语言属性值或有效语言
     */
    public static func getXmlLang(parser: XmlPullParser, xmlEnvironment: XmlEnvironment): ?String {
        let currentXmlLang = getXmlLang(parser)
        if (let Some(v) <- currentXmlLang) {
            return v
        }
        return xmlEnvironment.getEffectiveLanguage()
    }

    /**  
     * 从 XML 解析器中获取指定属性的 Internet 地址，忽略区域 ID 属性。
     *
     * @param parser XML 解析器实例
     * @param attribute 属性名称
     * @return 解析后的 Internet 地址对象，如果未找到则返回 null
     */
    public static func getInternetAddressIngoringZoneIdAttribute(parser: XmlPullParser, attribute: String): ?IPSocketAddress {
        let inetAddressString = parser.getAttributeValue(attribute) ?? return None
        return IPSocketAddress.tryParse(inetAddressString)
    }

    /**  
     * 获取 XML 中定义的语言属性值。
     *
     * @param parser XML 解析器实例
     * @return 语言属性值
     */
    public static func getXmlLang(parser: XmlPullParser): ?String {
        return parser.getAttributeValue(W3_XML_NAMESPACE, "lang")
    }
}
