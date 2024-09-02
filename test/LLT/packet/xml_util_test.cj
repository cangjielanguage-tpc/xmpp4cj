// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main
/*
@Test
public class XmlUtilTest {
    @TestCase
    public func prettyFormatXmlTest(): Unit {
        let uglyXml: String = "<foo attr1='value1' attr2='value2'><inner-element attr1='value1'>Test</inner-element></foo>"

        let prettyXml: String = XmlUtil.prettyFormatXml(uglyXml)

        assertEquals(
            "<foo attr1=\"value1\" attr2=\"value2\">\n  <inner-element attr1=\"value1\">Test</inner-element>\n</foo>\n",
            prettyXml
        )
    }

    @TestCase
    public func prettyFormatIncompleteXmlTest(): Unit {
        let uglyXml: String = "<foo attr1='value1' attr2='value2'><inner-element attr1='value1'>Test</inner-element>"

        let prettyXml: String = XmlUtil.prettyFormatXml(uglyXml)

        assertEquals("<foo attr1='value1' attr2='value2'><inner-element attr1='value1'>Test</inner-element>", prettyXml)
    }
}
*/
