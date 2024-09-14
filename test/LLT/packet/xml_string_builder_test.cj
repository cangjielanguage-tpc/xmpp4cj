// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_test_utils.cj --test
// EXEC: ./main

internal import xmpp4cj.packet.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class XmlStringBuilderTest {

    /**
     * Test that {@link XmlStringBuilder} does not omit the second inner namespace declaration.
     */
    @TestCase
    public func equalInnerNamespaceTest(): Unit {
        let innerOne: StandardExtensionElement = StandardExtensionElement.builder("inner", "inner-namespace").build()
        let innerTwo: StandardExtensionElement = StandardExtensionElement.builder("inner", "inner-namespace").build()

        let outer: StandardExtensionElement = StandardExtensionElement.builder("outer", "outer-namespace").addElement(
            innerOne).addElement(innerTwo).build()

        let expectedXml: String = "<outer xmlns='outer-namespace'><inner xmlns='inner-namespace'></inner><inner xmlns='inner-namespace'></inner></outer>"
        let actualXml: XmlStringBuilder = outer.toXML(XmlEnvironment.EMPTY)

        XmlAssertUtil.assertXmlSimilar(expectedXml, actualXml)

        let actualXmlTwo: StringBuilder = actualXml.toXML(XmlEnvironment.EMPTY)

        XmlAssertUtil.assertXmlSimilar(expectedXml, actualXmlTwo)
    }
}
