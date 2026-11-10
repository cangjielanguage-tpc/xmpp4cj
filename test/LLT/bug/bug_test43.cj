// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStaxXmlPullParser {
    var xmppXmlString = "".toArray()

    @TestCase
    func test_StaxXmlPullParser_allFunc02_01(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: Exception = @AssertThrows[Exception](staxXmlPullParser.nextTag())
        @Assert("XmlException: Failed to read data, idx: 0 out of size: 0.", e.toString())
    }
}
