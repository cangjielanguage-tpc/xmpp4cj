/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.xml

/**
 * XML解析器。
 */
public class XmppXmlParser {
    private static var xmlPullParserFactory: ?XmlPullParserFactory = StaxXmlPullParserFactory()

    /**
     * 获取XML解析器工厂类。
     *
     * @return XML解析器工厂类。
     * @throws Exception xmlPullParserFactory为Non的时候为空抛Exception异常。
     */
    public static func getXmlPullParserFactory(): XmlPullParserFactory {
        return xmlPullParserFactory ?? throw IllegalStateException("No XmlPullParserFactory registered")
    }

    /**
     * 设置XML解析器工厂类。
     *
     * @param xmlPullParserFactory XML解析器工厂类。
     */
    public static func setXmlPullParserFactory(xmlPullParserFactory: XmlPullParserFactory) {
        XmppXmlParser.xmlPullParserFactory = xmlPullParserFactory
    }

    /**
     * 创建一个适用于解析 XMPP 的新 XmlPullParser。
     * 这尤其意味着启用了 FEATURE_PROCESS_NAMESPACES。
     * <p>
     * 请注意，并非所有的 XmlPullParser 实现都会在解析器处于 START_ELEMENT 或 END_ELEMENT 时在 <code>getText()</code> 方法上返回一个字符串。
     * 因此，在使用解析器时，你不能依赖这种行为。
     * </p>
     *
     * @param reader 用于读取 XML 数据的读取器。
     * @return 一个适用于 XMPP 解析的 XmlPullParser。
     * @throws XmlPullParserException 如果发生 XmlPullParserException。
     */
    public static func newXmlParser(reader: InputStream): XmlPullParser {
        let xmlPullParserFactory = getXmlPullParserFactory()
        return xmlPullParserFactory.newXmlPullParser(reader)
    }
}
