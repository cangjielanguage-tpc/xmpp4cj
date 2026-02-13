import std.io.*
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.jid.*
internal import cangjie_tpc::xmpp4cj.xml.*

// TODO: Remove this class and replace it with SmackTestUtil.
public class TestUtils {
    private init() {
    }

    public static func getIQParser(stanza: String): XmlPullParser {
        return getParser(stanza, "iq")
    }

    public static func getMessageParser(stanza: String): XmlPullParser {
        return getParser(stanza, "message")
    }

    public static func getPresenceParser(stanza: String): XmlPullParser {
        return getParser(stanza, "presence")
    }

    public static func getParser(string: String): XmlPullParser {
        return getParser(string, None)
    }

    public static func getParser(string: String, startTag: ?String): XmlPullParser {
        let reader = ByteBuffer()
        reader.write(string.toArray())
        return getParser(reader, startTag)
    }

    private static func getParser(reader: InputStream, startTag: ?String): XmlPullParser {
        var parser: XmlPullParser
        try {
            parser = XmppXmlParser.newXmlParser(reader)
            if (startTag.isNone()) {
                while (parser.getEventType() != XmlPullParserEvent.START_ELEMENT) {
                    parser.next()
                }
                return parser
            }
            var found: Bool = false
            while (!found) {
                if ((parser.next() == XmlPullParserEvent.START_ELEMENT) && parser.getName() == startTag.getOrThrow()) {
                    found = true
                }
            }
            if (!found) {
                throw IllegalArgumentException("Can not find start tag '${startTag}'")
            }
        } catch (e: XmlPullParserException) {
            throw Exception(e.toString())
        } catch (e: IOException) {
            throw Exception(e.toString())
        }
        return parser
    }
}
