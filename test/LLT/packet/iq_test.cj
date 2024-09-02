// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj --test
// EXEC: ./main

@Test
public class IqTest {
    @TestCase
    public func testIqErrorWithChildElement(): Unit {
        let request: IQ = TestIQ()
        let error: StanzaError = StanzaError.getBuilder().setCondition(StanzaErrorCondition.bad_request).build()
        let errorIq: ErrorIQ = IQ.createErrorResponse(request, error)

        let expected: String = "<iq xmlns='jabber:client' id='42' type='error'>" +
            "<error type='modify'><bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/></error>" +
            "<test-iq xmlns='https://igniterealtime.org/projects/smack'/>" + "</iq>"
        assertXmlSimilar(expected, errorIq.toXML())
    }
}

/**
 * Tests that verifies the correct behavior of creating result and error IQ packets.
 *
 * @see <a href="http://xmpp.org/rfcs/rfc3920.html#stanzas-semantics-iq">IQ Semantics</a>
 * @author Guenther Niess
 */
@Test
public class IQResponseTest {
    private static let ELEMENT: String = "child"
    private static let NAMESPACE: String = "http://igniterealtime.org/protocol/test"

    /**
     * Test creating a simple and empty IQ response.
     * @throws XmppStringprepException if the provided string is invalid.
     */
    @TestCase
    public func testGeneratingSimpleResponse(): Unit {
        let request: IQ = TestIQ(ELEMENT, NAMESPACE)
        request.setFrom(JidCreate.froms("sender@test/Smack"))
        request.setTo(JidCreate.froms("receiver@test/Smack"))

        let result: IQ = IQ.createResultIQ(request)

        assertEquals(IQType.result, result.getType())
        assertNotNull(result.getStanzaId())
        assertEquals(request.getStanzaId(), result.getStanzaId())
        assertEquals(request.getFrom(), result.getTo())
        assertEquals(request.getTo(), result.getFrom())
        assertEquals("", result.getChildElementXML().toString())
    }

    /**
     * Test creating a error response based on an IQ request.
     * @throws XmppStringprepException if the provided string is invalid.
     */
    @TestCase
    public func testGeneratingValidErrorResponse(): Unit {
        let error: StanzaError = StanzaError.getBuilder(StanzaErrorCondition.bad_request).build()
        let request: IQ = TestIQ(ELEMENT, NAMESPACE)

        request.setType(IQType.set)
        request.setFrom(JidCreate.froms("sender@test/Smack"))
        request.setTo(JidCreate.froms("receiver@test/Smack"))

        let result: IQ = IQ.createErrorResponse(request, error)

        assertEquals(IQType.error, result.getType())
        assertNotNull(result.getStanzaId())
        assertEquals(request.getStanzaId(), result.getStanzaId())
        assertEquals(request.getFrom(), result.getTo())
        assertEquals(error.toXML().toString(), result.getError()().toXML().toString())
        // TODO this test was never valid
        // assertEquals(CHILD_ELEMENT, result.getChildElementXML())
    }

    /**
     * According to <a href="http://xmpp.org/rfcs/rfc3920.html#stanzas-semantics-iq"
     * >RFC3920: IQ Semantics</a> we shouldn't respond to an IQ of type result.
     * @throws XmppStringprepException if the provided string is invalid.
     */
    @TestCase
    public func testGeneratingResponseBasedOnResult(): Unit {
        let request: IQ = TestIQ(ELEMENT, NAMESPACE)

        request.setType(IQType.result)
        request.setFrom(JidCreate.froms("sender@test/Smack"))
        request.setTo(JidCreate.froms("receiver@test/Smack"))

        try {
            IQ.createResultIQ(request)
        } catch (e: IllegalArgumentException) {
            return
        }

        fail("It shouldn't be possible to generate a response for a result IQ!")
    }

    /**
     * According to <a href="http://xmpp.org/rfcs/rfc3920.html#stanzas-semantics-iq"
     * >RFC3920: IQ Semantics</a> we shouldn't respond to an IQ of type error.
     * @throws XmppStringprepException if the provided string is invalid.
     */
    @TestCase
    public func testGeneratingErrorBasedOnError(): Unit {
        let error: StanzaError = StanzaError.getBuilder(StanzaErrorCondition.bad_request).build()
        let request: IQ = TestIQ(ELEMENT, NAMESPACE)

        request.setType(IQType.error)
        request.setFrom(JidCreate.froms("sender@test/Smack"))
        request.setTo(JidCreate.froms("receiver@test/Smack"))
        request.setError(error)

        try {
            IQ.createErrorResponse(request, error)
        } catch (e: IllegalArgumentException) {
            return
        }

        fail("It shouldn't be possible to generate a response for a error IQ!")
    }
}

public class TestIQ <: SimpleIQ {
    public init() {
        // this("test-iq", SmackConfiguration.SMACK_URL_STRING)
        this("test-iq", "https://igniterealtime.org/projects/smack")
    }

    public init(element: String, namespace: String) {
        super(StanzaBuilder.buildIqData("42"), element, namespace)
    }

    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        if (getChildElementName().size == 0) {
            return None
        }
        return super.getIQChildElementBuilder(xml)
    }
}
