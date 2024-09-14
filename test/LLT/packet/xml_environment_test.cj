// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj --test
// EXEC: ./main 
//--filter=*.setPresenceModeTest

@Test
public class XmlEnvironmentTest {
    @TestCase
    public func testNamespaceScope(): Unit {
        let outerNamespace: String = "outerNamespace"

        let outer: XmlEnvironment = XmlEnvironment.builder().withNamespace(outerNamespace).build()
        let inner: XmlEnvironment = XmlEnvironment.builder().withNext(outer).build()

        assertEquals(outerNamespace, inner.getEffectiveNamespace())
    }

    @TestCase
    public func testLanguageScope(): Unit {
        let outerLanguage: String = "outerLanguage"

        let outer: XmlEnvironment = XmlEnvironment.builder().withLanguage(outerLanguage).build()
        let inner: XmlEnvironment = XmlEnvironment.builder().withNext(outer).build()

        assertEquals(outerLanguage, inner.getEffectiveLanguage())
    }
}
