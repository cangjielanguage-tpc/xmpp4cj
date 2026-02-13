// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStaxXmlPullParser{

    var xmppXmlString="""
<stream:stream>
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>
<presence/>
<message to='william_duan@jabber.org' from='test_account@jabber.org' type='chat'><body>Hello</body></message>
<presence type='unavailable'/>
</stream:stream>"""

    @TestCase
    func test_StaxXmlPullParser_allFunc02_02_22(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e:XmlPullParserException=@AssertThrows[XmlPullParserException](staxXmlPullParser.nextText())
        @Assert(e.toString(),"XmlPullParserException: parser must be on START_ELEMENT to read next text")
    }
}
