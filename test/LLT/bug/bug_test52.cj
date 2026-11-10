// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStaxXmlPullParser {
    var xmppXmlString = """
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>
<presence/>
<message to='william_duan@jabber.org' from='test_account@jabber.org' type='chat'><body>Hello</body></message>
<presence type='unavailable'/>"""
        .toArray()

    @TestCase
    func test_StaxXmlPullParser_allFunc02_03_13(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: XmlPullParserException = @AssertThrows[XmlPullParserException](staxXmlPullParser.getAttributeType(0))
        @Assert("XmlPullParserException: No such attribute", e.toString())
    }
}
