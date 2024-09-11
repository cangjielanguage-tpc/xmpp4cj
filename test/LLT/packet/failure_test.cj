// DEPENDENCE: ../z_test.cj
// DEPENDENCE: xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_test_utils.cj --test
// EXEC: ./main
@Test
public class FailureTest {
    // throws SAXException, IOException
    @TestCase
    public func simpleFailureTest(): Unit {
        let failure: Failure = Failure(FailureCompressFailureError.processing_failed)
        let xml: CharSequence = failure.toXML()

        let expectedXml: String = "<failure xmlns='http://jabber.org/protocol/compress'><processing-failed/></failure>"

        assertXmlSimilar(expectedXml, xml.toString())
    }
    // throws SAXException, IOException 
    @TestCase
    public func withStanzaErrrorFailureTest(): Unit {
        let stanzaError: StanzaError = StanzaError.getBuilder().setCondition(StanzaErrorCondition.bad_request).build()
        let failure: Failure = Failure(FailureCompressFailureError.setup_failed, stanzaError)
        let xml: CharSequence = failure.toXML()

        let expectedXml: String = "<failure xmlns='http://jabber.org/protocol/compress'>" + "<setup-failed/>" +
            "<error xmlns='jabber:client' type='modify'>" + "<bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>" +
            "</error>" + "</failure>"

        assertXmlSimilar(expectedXml, xml.toString())
    }
}
