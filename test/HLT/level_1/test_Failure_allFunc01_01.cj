// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjFailure{


    var failure02=Failure(FailureCompressFailureError.setup_failed)
    var stanzaErrorBuilder=StanzaError.froms(StanzaErrorCondition.forbidden,"StanzaErrorBuilder_me")
    var failure04=Failure(FailureCompressFailureError.processing_failed,stanzaErrorBuilder.build())

    var enclosingNamespace01=None<XmlEnvironment>
    var xmlEnvironment=XmlEnvironment("my namespace")
    var enclosingNamespace02=Some(xmlEnvironment)

    @TestCase
    func test_Failure_Init01_01(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](Failure(None<FailureCompressFailureError>))
        @Assert(e.toString(),"IllegalArgumentException: Can not provide None argument")
    }
    @TestCase
    func test_Failure_Init03_01(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](Failure(None<FailureCompressFailureError>,None<StanzaError>))
        @Assert(e.toString(),"IllegalArgumentException: Can not provide None argument")
    }
    @TestCase
    func test_Failure_toXML_1_02(): Unit {
        var actXmlStringBuilder=failure02.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<failure xmlns='http://jabber.org/protocol/compress'><setup-failed/></failure>")
    }
    @TestCase
    func test_Failure_toXML_1_04(): Unit {
        var actXmlStringBuilder=failure04.toXML(enclosingNamespace01)
        @Assert(actXmlStringBuilder.toString(),"<failure xmlns='http://jabber.org/protocol/compress'><processing-failed/><error xmlns='jabber:client' type='auth'><forbidden xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/><text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' xml:lang='en'>StanzaErrorBuilder_me</text></error></failure>")
    }


    @TestCase
    func test_Failure_toXML_2_02(): Unit {
        var actXmlStringBuilder=failure02.toXML(enclosingNamespace02)
        @Assert(actXmlStringBuilder.toString(),"<failure xmlns='http://jabber.org/protocol/compress'><setup-failed/></failure>")
    }

    @TestCase
    func test_Failure_toXML_2_04(): Unit {
        var actXmlStringBuilder=failure04.toXML(enclosingNamespace02)
        @Assert(actXmlStringBuilder.toString(),"<failure xmlns='http://jabber.org/protocol/compress'><processing-failed/><error xmlns='jabber:client' type='auth'><forbidden xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/><text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' xml:lang='en'>StanzaErrorBuilder_me</text></error></failure>")
    }

    @TestCase
    func test_Failure_StaticValue_3(): Unit {
        @Assert(Failure.ELEMENT,"failure")
        @Assert(Failure.NAMESPACE,"http://jabber.org/protocol/compress")
        @Assert(Failure.QNAME.toString(), "{http://jabber.org/protocol/compress}failure")
    }
    @TestCase
    func test_Failure_getElementName_4(): Unit {
        @Assert(failure02.getElementName(),"failure")
        @Assert(failure04.getElementName(),"failure")
    }
    @TestCase
    func test_Failure_getNamespace_5(): Unit {
        @Assert(failure02.getNamespace(),"http://jabber.org/protocol/compress")
        @Assert(failure04.getNamespace(),"http://jabber.org/protocol/compress")
    }
    @TestCase
    func test_Failure_getFailureCompressFailureError_6(): Unit {
        @Assert(failure02.getFailureCompressFailureError(),FailureCompressFailureError.setup_failed)
        @Assert(failure04.getFailureCompressFailureError(),FailureCompressFailureError.processing_failed)
    }
    @TestCase
    func test_Failure_getStanzaError_7(): Unit {
        var actXmlStringBuilder02=failure02.getStanzaError()//.getOrThrow().toXML(enclosingNamespace02)
        var actXmlStringBuilder04=failure04.getStanzaError().getOrThrow().toXML(enclosingNamespace02)
        @Assert(actXmlStringBuilder02.isNone(),true)
        @Assert(actXmlStringBuilder04.toString(),"<error xmlns='jabber:client' type='auth'><forbidden xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/><text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' xml:lang='en'>StanzaErrorBuilder_me</text></error>")
    }
}
