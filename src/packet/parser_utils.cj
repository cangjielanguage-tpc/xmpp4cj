/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class ParserUtils {
    static let W3_XML_NAMESPACE = "http://www.w3.org/XML/1998/namespace"
    public static func getXmlLang(parser: XmlPullParser): String {
        return parser.getAttributeValue(W3_XML_NAMESPACE, "lang")
    }

    // throws XmlPullParserException
    public static func assertAtStartTag(parser: XmlPullParser): Unit {
        assert(parser.getEventType() == XmlPullParserEvent.START_ELEMENT)
    }

    // throws XmlPullParserException
    public static func forwardToEndTagOfDepth(parser: XmlPullParser, depth: Int): Unit {
        var event = parser.getEventType()
        while (!(event == XmlPullParserEvent.END_ELEMENT && parser.getDepth() == depth)) {
            assert(event != XmlPullParserEvent.END_DOCUMENT)
            event = parser.next()
        }
    }
}
