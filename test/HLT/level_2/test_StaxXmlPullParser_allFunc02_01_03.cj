// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStaxXmlPullParser{
    var xmppXmlString=""
    @TestCase
    func test_StaxXmlPullParser_allFunc02_01_22(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e:XmlPullParserException=@AssertThrows[XmlPullParserException](staxXmlPullParser.nextText())
        @Assert(e.toString(),"XmlPullParserException: parser must be on START_ELEMENT to read next text")
    }
}
