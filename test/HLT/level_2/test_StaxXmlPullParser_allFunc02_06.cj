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
</stream:stream>
<stream:stream>
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>
<presence/>
<message to='william_duan@jabber.org' from='test_account@jabber.org' type='chat'><body>Hello</body></message>
<presence type='unavailable'/>
</stream:stream>"""

    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_1(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e:UnsupportedException=@AssertThrows[UnsupportedException](staxXmlPullParser.isWhiteSpace())
        @Assert(e.toString(),"UnsupportedException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_2(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getNamespaceCount(),0)
    }
    // @TestCase
    // func test_StaxXmlPullParser_allFunc02_06_3(): Unit {
    //     var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
    //     let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getNamespacePrefix(0))
    //     @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    // }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_4(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getNamespaceUri(0))
        // @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_5(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getText(),"")
   }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_6(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:NoneValueException=@AssertThrows[NoneValueException](staxXmlPullParser.getName())
        @Assert(e.toString(),"NoneValueException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_7(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:NoneValueException=@AssertThrows[NoneValueException](staxXmlPullParser.getQName())
        @Assert(e.toString(),"NoneValueException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_8(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getAttributeCount(),0)
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_9(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getAttributeNamespace(0))
        @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_10(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getAttributeName(0))
        @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_11(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getAttributeQName(0))
        @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_12(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getAttributePrefix(0))
        @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_13(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:XmlPullParserException=@AssertThrows[XmlPullParserException](staxXmlPullParser.getAttributeType(0))
        @Assert(e.toString(),"XmlPullParserException: No such attribute")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_14(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString);
        let e:IndexOutOfBoundsException=@AssertThrows[IndexOutOfBoundsException](staxXmlPullParser.getAttributeValue(0))
        @Assert(e.toString(),"IndexOutOfBoundsException: index: 0, size: 0")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_15(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        @Assert(staxXmlPullParser.getAttributeValue("Attributenamespace", "Attributename").isNone(),true)
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_16(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e=@AssertThrows[UnsupportedException](staxXmlPullParser.getLineNumber())
        @Assert(e.toString(),"UnsupportedException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_17(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e=@AssertThrows[UnsupportedException](staxXmlPullParser.getColumnNumber())
        @Assert(e.toString(),"UnsupportedException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_18(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e=@AssertThrows[UnsupportedException](staxXmlPullParser.getProperty(""))
        @Assert(e.toString(),"UnsupportedException")
    }
    @TestCase
    func test_StaxXmlPullParser_allFunc02_06_19(): Unit {
        var staxXmlPullParser=getStaxXmlPullParser(xmppXmlString)
        let e=@AssertThrows[UnsupportedException](staxXmlPullParser.getPositionDescription())
        @Assert(e.toString(),"UnsupportedException")
    }
}
