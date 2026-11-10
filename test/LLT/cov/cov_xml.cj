// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

@Test
public func test_XmppXmlParser1(): Unit {
    let xmppXmlParser: XmppXmlParser = XmppXmlParser()
    let xmlPullParserFactory1: XmlPullParserFactory = StaxXmlPullParserFactory()
    XmppXmlParser.setXmlPullParserFactory(xmlPullParserFactory1)
    let xmlPullParserFactory2: XmlPullParserFactory = XmppXmlParser.getXmlPullParserFactory()
}
