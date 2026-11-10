// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class FailureProviderTest {
    @TestCase
    func simpleFailureTest() {
        let xml: String = "<failure xmlns='http://jabber.org/protocol/compress'><processing-failed/></failure>"
        let parser: XmlPullParser = PacketParserUtils.getParserFor(xml)
        let failure: Failure = FailureProvider.INSTANCE.parse(parser)
        @Assert(FailureCompressFailureError.processing_failed,failure.getFailureCompressFailureError())
    }

    @TestCase
    func withStanzaErrrorFailureTest() {
        let xml: String = "<failure xmlns='http://jabber.org/protocol/compress'>" + "<setup-failed/>" +
            "<error xmlns='jabber:client' type='modify'>" + "<bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>" +
            "</error>" + "</failure>"
        let parser: XmlPullParser = PacketParserUtils.getParserFor(xml)
        let failure: Failure = FailureProvider.INSTANCE.parse(parser)
        @Assert(FailureCompressFailureError.setup_failed,failure.getFailureCompressFailureError())
        let error: StanzaError = failure.getStanzaError().getOrThrow()
        @Assert(StanzaErrorCondition.bad_request,error.getCondition())
    }
}
