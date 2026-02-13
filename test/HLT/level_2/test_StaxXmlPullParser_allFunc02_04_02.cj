// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStaxXmlPullParser{
    var xmppXmlString="""
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"""
    @TestCase
    func test_StaxXmlPullParser_allFunc02_04_21(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.next(),XmlPullParserEvent.START_ELEMENT)
    }

}
