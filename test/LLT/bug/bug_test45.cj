// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStaxXmlPullParser {
    var xmppXmlString = "".toArray()

    @TestCase
    func test_StaxXmlPullParser_allFunc01_01_9(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: NoneValueException = @AssertThrows[NoneValueException](staxXmlPullParser.getNamespace())
        @Assert("NoneValueException", e.toString())
    }

    @TestCase
    func test_StaxXmlPullParser_allFunc01_10(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: NoneValueException = @AssertThrows[NoneValueException](staxXmlPullParser.getPrefix())
        @Assert("NoneValueException", e.toString())
    }
}
