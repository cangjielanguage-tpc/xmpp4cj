// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStaxXmlPullParser{
    var xmppXmlString=""
    @TestCase
    func test_StaxXmlPullParser_allFunc02_01_21(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e:Exception=@AssertThrows[Exception](staxXmlPullParser.next())
        @Assert(e.toString(),"XmlException: Failed to read data, idx: 0 out of size: 0.")
    }
}
