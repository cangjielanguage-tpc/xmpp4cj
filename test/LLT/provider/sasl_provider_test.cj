// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f xml_test_utils.cj smack_test_util.cj z_test.cj --test --error-count-limit all
// EXEC: ./main 
//--filter=*.*

@Test
public class SaslProviderTest {
    @TestCase[parserKind in [ StAX ]]
    public func parseSASLFailureSimple(parserKind: XmlPullParserKind): Unit {
        // @formatter:off
        let saslFailureString = XMLBuilder.create(SaslNonzaSASLFailure.ELEMENT, SaslNonza.NAMESPACE).e(
            SASLError.account_disabled.toString()).asString()
        // @formatter:on
        let saslFailure: SaslNonzaSASLFailure = SmackTestUtil.parse<SaslFailureProvider, SaslNonzaSASLFailure>(
            saslFailureString,
            parserKind
        )
        assertXmlSimilar(saslFailureString, saslFailure.toString())
    }

    @TestCase[parserKind in [ StAX ]]
    public func parseSASLFailureExtended(parserKind: XmlPullParserKind): Unit {
        // @formatter:off
        let saslFailureString = XMLBuilder.create(SaslNonzaSASLFailure.ELEMENT, SaslNonza.NAMESPACE).e(
            SASLError.account_disabled.toString()).up().e("text").a("xml:lang", "en").t(
            "Call 212-555-1212 for assistance.").up().e("text").a("xml:lang", "de").t(
            "Bitte wenden sie sich an (04321) 123-4444").up().e("text").t("Wusel dusel").asString()
        // @formatter:on
        let saslFailure: SaslNonzaSASLFailure = SmackTestUtil.parse<SaslFailureProvider, SaslNonzaSASLFailure>(
            saslFailureString,
            parserKind
        )
        println(saslFailureString)
        let s1 = saslFailure.toXML(StreamOpen.CLIENT_NAMESPACE)
        assertXmlSimilar(saslFailureString, s1)
    }
}
