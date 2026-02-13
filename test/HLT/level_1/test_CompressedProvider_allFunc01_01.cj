// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjCompressedProvider{
    var compressedProvider01=CompressedProvider.INSTANCE

    @TestCase
    func test_CompressedProvider_parse_1(): Unit {
        var xmppXmlString="<query xmlns='jabber:iq:roster'/>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        var enclosingNamespace01=None<XmlEnvironment>

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,10,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_CompressedProvider_parse_2(): Unit {
        var xmppXmlString="<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        var enclosingNamespace01=None<XmlEnvironment>

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,10,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_CompressedProvider_parse_3(): Unit {
        var xmppXmlString="<query xmlns='jabber:iq:roster'/>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)

        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,10,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_CompressedProvider_parse_4(): Unit {
        var xmppXmlString="<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)

        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,10,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_CompressedProvider_parse_5(): Unit {
        var xmppXmlString="<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)

        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,Int64.Max,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_CompressedProvider_parse_6(): Unit {
        var xmppXmlString="<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)

        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,Int64.Min,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_CompressedProvider_parse_7(): Unit {
        var xmppXmlString="<iq type='get'><query xmlns='jabber:iq:roster'/></iq>"
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)

        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)

        var actCompressed=compressedProvider01.parse(staxXmlPullParser,0,enclosingNamespace01)
        var actXmlStringBuilder=actCompressed.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
}
