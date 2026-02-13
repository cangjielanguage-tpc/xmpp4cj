
// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj test_utils.cj --test
// EXEC: ./main 
//--filter=*.*

import cangjie_tpc::xmpp4cj.packet.*

@Test
public class ParsingExceptionTest {
    private static let EXTENSION2: String = "<extension2 xmlns='namespace'>" + "<bar node='testNode'>" +
        "<i id='testid1'>" + "text content" + "</i>" + "</bar>" + "</extension2>"

    @BeforeEach
    public func init0(): Unit {
        ProviderManager.addExtensionProvider(ThrowException.ELEMENT, ThrowException.NAMESPACE, ThrowException())
    }

    @AfterEach
    public func tini(): Unit {
        ProviderManager.removeExtensionProvider(ThrowException.ELEMENT, ThrowException.NAMESPACE)
    }

    @TestCase
    public func consumeUnparsedInput(): Unit {
        let MESSAGE_EXCEPTION_ELEMENT: String = "<${ThrowException.ELEMENT} xmlns='${ThrowException.NAMESPACE}'><nothingInHere/></${ThrowException.ELEMENT}>"
        let s1 = "<message from='user@server.example' to='francisco@denmark.lit' id='foo'>${MESSAGE_EXCEPTION_ELEMENT}${EXTENSION2}</message>"
        let parser: XmlPullParser = TestUtils.getMessageParser(s1)
        let parserDepth: Int = parser.getDepth()
        var content: ?String = None
        try {
            PacketParserUtils.parseMessage(parser)
        } catch (e: Exception) {
            content = PacketParserUtils.parseContentDepth(parser, parserDepth, false)
        }
        assertEquals("${MESSAGE_EXCEPTION_ELEMENT}${EXTENSION2}</message>", content.getOrThrow())
    }
}

class ThrowException <: ExtensionElementProvider<ExtensionElement> {
    public static let ELEMENT: String = "exception"
    public static let NAMESPACE: String = "http://smack.jivesoftware.org/exception"
    init() {
        super("ExtensionElement")
    }
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): ExtensionElement {
        throw Exception("Test Exception")
    }
}
