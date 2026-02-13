// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStaxXmlPullParser{
    var xmppXmlString="""
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"""
    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_1(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getInputEncoding(),"UTF-8")//null
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_2(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getNamespace ("jabber").isNone(),true)//null
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_3(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getDepth (),0)//0
    }

    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_4(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e:NoneValueException=@AssertThrows[NoneValueException](staxXmlPullParser.getNamespace())
        @Assert(e.toString(),"NoneValueException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_5(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e:NoneValueException=@AssertThrows[NoneValueException](staxXmlPullParser.getPrefix())
        @Assert(e.toString(),"NoneValueException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_6(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.supportsRoundtrip(),false)//false
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc01_04_7(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getEventType().toString(),"START_DOCUMENT")
    }
}
