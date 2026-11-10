// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStaxXmlPullParser {
    var xmppXmlString = "".toArray()

    @TestCase
    func test_StaxXmlPullParser_allFunc01_01_1(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](staxXmlPullParser.getProperty(""))
        @Assert("UnsupportedException", e.toString())
    }

    @TestCase
    func test_StaxXmlPullParser_allFunc01_01_5(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](staxXmlPullParser.getPositionDescription())
        @Assert("UnsupportedException", e.toString())
    }

    @TestCase
    func test_StaxXmlPullParser_allFunc01_01_6(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](staxXmlPullParser.getLineNumber())
        @Assert("UnsupportedException", e.toString())
    }

    @TestCase
    func test_StaxXmlPullParser_allFunc01_01_7(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](staxXmlPullParser.getColumnNumber())
        @Assert("UnsupportedException", e.toString())
    }

    @TestCase
    func test_StaxXmlPullParser_allFunc01_01_8(): Unit {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write(xmppXmlString)
        let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
        let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](staxXmlPullParser.isWhiteSpace())
        @Assert("UnsupportedException", e.toString())
    }
}
