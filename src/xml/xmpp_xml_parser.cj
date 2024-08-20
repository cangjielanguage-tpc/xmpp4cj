/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

public class XmppXmlParser {
    private static var xmlPullParserFactory: ?XmlPullParserFactory = StaxXmlPullParserFactory()

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
    public static func newXmlParser(reader: InputStream): XmlPullParser {
        let xmlPullParserFactory = getXmlPullParserFactory()
        return xmlPullParserFactory.newXmlPullParser(reader)
    }
}
