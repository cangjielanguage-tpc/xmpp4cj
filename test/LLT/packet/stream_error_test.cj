// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: xml_test_utils.cj
// DEPENDENCE: smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj smack_test_util.cj --test
/// EXEC: ./main 
//--filter=*.setPresenceModeTest
/* TODO */
@Test
public class StreamErrorTest {
    @TestCase[parserKind in [ StAX ]]
    public func testParsingOfSimpleStreamError(parserKind: XmlPullParserKind): Unit {
        let xml: String =
            // Usually the stream:stream element has more attributes (to, version, ...)
            // We omit those, since they are not relevant for testing
            "<stream:stream from='im.example.com' id='++TR84Sm6A3hnt3Q065SnAbbk3Y=' xmlns:stream='http://etherx.jabber.org/streams'>" +
            "<stream:error>" + "<conflict xmlns='urn:ietf:params:xml:ns:xmpp-streams' /> +" + "</stream:error>" +
            "</stream:stream>"

        let parser: XmlPullParser = SmackTestUtil.getParserFor(xml, "error", parserKind)
        let error: StreamError = PacketParserUtils.parseStreamError(parser)

        assertNotNull(error)
        assertEquals(StreamErrorCondition.conflict, error.getCondition())
    }

    @TestCase[parserKind in [ StAX ]]
    public func testParsingOfStreamErrorWithText(parserKind: XmlPullParserKind): Unit {
        let xml: String =
            // Usually the stream:stream element has more attributes (to, version, ...)
            // We omit those, since they are not relevant for testing
            "<stream:stream from='im.example.com' id='++TR84Sm6A3hnt3Q065SnAbbk3Y=' xmlns:stream='http://etherx.jabber.org/streams'>" +
            "<stream:error>" + "<conflict xmlns='urn:ietf:params:xml:ns:xmpp-streams' />" +
            "<text xml:lang='' xmlns='urn:ietf:params:xml:ns:xmpp-streams'>" + "Replaced by new connection" + "</text>" +
            "</stream:error>" + "</stream:stream>"

        let parser: XmlPullParser = SmackTestUtil.getParserFor(xml, "error", parserKind)
        let error: StreamError = PacketParserUtils.parseStreamError(parser)

        assertNotNull(error)
        assertEquals(StreamErrorCondition.conflict, error.getCondition())
        assertEquals("Replaced by new connection", error.getDescriptiveText())
    }

    @TestCase[parserKind in [ StAX ]]
    public func testParsingOfStreamErrorWithTextAndOptionalElement(parserKind: XmlPullParserKind): Unit {
        let xml: String =
            // Usually the stream:stream element has more attributes (to, version, ...)
            // We omit those, since they are not relevant for testing
            "<stream:stream from='im.example.com' id='++TR84Sm6A3hnt3Q065SnAbbk3Y=' xmlns:stream='http://etherx.jabber.org/streams'>" +
            "<stream:error>" + "<conflict xmlns='urn:ietf:params:xml:ns:xmpp-streams' />" +
            "<text xml:lang='' xmlns='urn:ietf:params:xml:ns:xmpp-streams'>" + "Replaced by new connection" + "</text>" +
            "<appSpecificElement xmlns='myns'>" + "Text contents of application-specific condition element: Foo Bar" +
            "</appSpecificElement>" + "</stream:error>" + "</stream:stream>"

        let parser: XmlPullParser = SmackTestUtil.getParserFor(xml, "error", parserKind)
        let error: StreamError = PacketParserUtils.parseStreamError(parser)

        assertNotNull(error)
        assertEquals(StreamErrorCondition.conflict, error.getCondition())
        assertEquals("Replaced by new connection", error.getDescriptiveText())
        let appSpecificElement: ?ExtensionElement = error.getExtension("appSpecificElement", "myns")
        assertNotNull(appSpecificElement)
    }

    @TestCase[parserKind in [ StAX ]]
    public func testStreamErrorXmlNotWellFormed(parserKind: XmlPullParserKind): Unit {
        let xml: String =
            // Usually the stream:stream element has more attributes (to, version, ...)
            // We omit those, since they are not relevant for testing
            "<stream:stream from='im.example.com' id='++TR84Sm6A3hnt3Q065SnAbbk3Y=' xmlns:stream='http://etherx.jabber.org/streams'>" +
            "<stream:error><xml-not-well-formed xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>" +
            "</stream:stream>"

        let parser: XmlPullParser = SmackTestUtil.getParserFor(xml, "error", parserKind)
        let error: StreamError = PacketParserUtils.parseStreamError(parser)

        assertNotNull(error)
        assertEquals(StreamErrorCondition.not_well_formed, error.getCondition())
    }
}
