// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStaxXmlPullParser{

    var xmppXmlString="""
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>
<presence/>
<message to='william_duan@jabber.org' from='test_account@jabber.org' type='chat'><body>Hello</body></message>
<presence type='unavailable'/>"""

    @TestCase
    func test_StaxXmlPullParser_allFunc02_03_20(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        var xmlPullParserTagEvent=staxXmlPullParser.nextTag()
        match(xmlPullParserTagEvent){
            case XmlPullParserTagEvent.START_ELEMENT =>@Assert(true)
            case _ => @Assert(false)
        }
    }
}
