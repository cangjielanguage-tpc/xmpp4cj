// DEPENDENCE: z_test.cj xml_splitter_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_splitter_test_util.cj --test
// EXEC: ./main
@Test
public class XmlSplitterTest {
    @TestCase
    public func simpleTest(): Unit {
        let element = "<ele att=\'foo\'>bar</ele>"
        XmlSplitterTestUtil.xmlSplitterTest([element])
    }

    @TestCase
    public func emptyElementTest(): Unit {
        XmlSplitterTestUtil.xmlSplitterTest(["<ele att=\'foo\'><empty /></ele>"])
    }

    @TestCase
    public func attributeValueWithRightAngleBracketTest(): Unit {
        XmlSplitterTestUtil.xmlSplitterTest(["<x a=\'/>\'>c</x>"])
    }
}
