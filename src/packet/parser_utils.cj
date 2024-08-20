/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class ParserUtils {
    static let W3_XML_NAMESPACE = "http://www.w3.org/XML/1998/namespace"
    public static func getXmlLang(parser: XmlPullParser): ?String {
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

    // throws XmppStringprepException
    public static func getJidAttribute(parser: XmlPullParser, name: String): ?Jid {
        let jidString: ?String = parser.getAttributeValue("", name)
        if (let Some(jidString) <- jidString) {
            JidCreate.froms(jidString)
        } else {
            None
        }
    }
}
