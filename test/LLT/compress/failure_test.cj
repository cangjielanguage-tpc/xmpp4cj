// DEPENDENCE: ../z_test.cj ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_test_utils.cj --test
// EXEC: ./main

@Test
public class FailureTest {
    @TestCase
    public func simpleFailureTest() {
        let failure: Failure = Failure(FailureCompressFailureError.processing_failed)
        let xml = failure.toXML()
        let expectedXml: String = "<failure xmlns='http://jabber.org/protocol/compress'><processing-failed/></failure>"
        XmlAssertUtil.assertXmlSimilar(expectedXml, xml.toString())
    }

    @TestCase
    public func withStanzaErrrorFailureTest() {
        let stanzaError: StanzaError = StanzaError.getBuilder().setCondition(StanzaErrorCondition.bad_request).build()
        let failure: Failure = Failure(FailureCompressFailureError.setup_failed, stanzaError)
        let xml = failure.toXML()
        let expectedXml: String = "<failure xmlns='http://jabber.org/protocol/compress'>" + "<setup-failed/>" +
            "<error xmlns='jabber:client' type='modify'>" + "<bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>" +
            "</error>" + "</failure>"
        XmlAssertUtil.assertXmlSimilar(expectedXml, xml.toString())
    }
}
