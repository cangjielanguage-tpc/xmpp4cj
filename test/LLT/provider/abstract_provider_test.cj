// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f xml_test_utils.cj smack_test_util.cj z_test.cj --test --error-count-limit all
// EXEC: ./main 
//--filter=*.*

import xmpp4cj.packet.*

@Test
public class AbstractProviderTest {
    private static let NUMBER_FORMAT_THROWING_PROVIDER: ExtensionElementProvider<ExtensionElement> = ExtensionElementProvider01(
        )
    private static let MESSAGE: String = "dummy message";
    private static let VALUE: Int64 = 14768234;
    private static let PARSE_EXCEPTION_THROWING_PROVIDER: ExtensionElementProvider<ExtensionElement> = ExtensionElementProvider02(
        )

    @TestCase
    public func testWrapsNumberFormatException() {
        let dummyElement: String = "<empty-element/>"
        let parser: XmlPullParser = PacketParserUtils.getParserFor(dummyElement)
        var isBool = false
        try {
            NUMBER_FORMAT_THROWING_PROVIDER.parse(parser)
            isBool = true
        } catch (e: Exception) {
            isBool = false
        }
        Assert.assertEquals(false, isBool)
    }

    @TestCase
    public func testWrapsParseException() {
        let dummyElement: String = "<empty-element/>"
        let parser: XmlPullParser = PacketParserUtils.getParserFor(dummyElement)
        var isBool = false
        try {
            PARSE_EXCEPTION_THROWING_PROVIDER.parse(parser)
            isBool = true
        } catch (e: Exception) {
            isBool = false
        }
        Assert.assertEquals(false, isBool)
    }
}

public class ExtensionElementProvider01 <: ExtensionElementProvider<ExtensionElement> {
    init() {
        super("ExtensionElement")
    }
    public func parse(parser: XmlPullParser, initialDepth: Int64, xmlEnvironment: ?XmlEnvironment): ExtensionElement {
        throw Exception()
    }
}

public class ExtensionElementProvider02 <: ExtensionElementProvider<ExtensionElement> {
    init() {
        super("ExtensionElement")
    }
    public func parse(parser: XmlPullParser, initialDepth: Int64, xmlEnvironment: ?XmlEnvironment): ExtensionElement {
        throw Exception()
    }
}
