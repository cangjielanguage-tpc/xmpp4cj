// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f xml_test_utils.cj smack_test_util.cj z_test.cj --test --error-count-limit all
// EXEC: ./main 
//--filter=*.*

import cangjie_tpc::xmpp4cj.packet.*

@Test
public class StandardExtensionElementParserTest {
    @TestCase
    public func buildAndParse(): Unit {
        let builder: StandardExtensionElementBuilder = StandardExtensionElement.builder("foo", "ns1")
        builder.addAttribute("attr1", "attr1-value")
        builder.addElement(StandardExtensionElement.builder("bar", "ns2").addAttribute("attr2", "attr2-value").build())
        builder.addElement("another-element", "another-element-text")
        let elementString: String = builder.build().toXML().toString()
        let xmlPullParser: XmlPullParser = PacketParserUtils.getParserFor(elementString)
        let standardExtensionElementProvider: StandardExtensionElementProvider = StandardExtensionElementProvider
            .INSTANCE
        let parsedElement: StandardExtensionElement = standardExtensionElementProvider.parse(xmlPullParser)
        @Assert("foo", parsedElement.getElementName())
        @Assert("ns1", parsedElement.getNamespace())
        @Assert("attr1-value", parsedElement.getAttributeValue("attr1"))
        let barNs2Element: ?StandardExtensionElement = parsedElement.getFirstElement("bar", "ns2")
        @Assert("bar", barNs2Element?.getElementName())
        @Assert("ns2", barNs2Element?.getNamespace())
        @Assert("attr2-value", barNs2Element?.getAttributeValue("attr2"))
        let standardExtensionElement: ?StandardExtensionElement = parsedElement.getFirstElement("another-element")
        @Assert("another-element-text", parsedElement.getFirstElement("another-element")?.getText())
        let parsedElementString: String = parsedElement.toXML().toString()
        @Assert(elementString, parsedElementString)
    }

    @TestCase
    public func buildWithAttrNamespacesAndParse(): Unit {
        let builder: StandardExtensionElementBuilder = StandardExtensionElement.builder("foo", "ns1-value")
        builder.addAttribute("xmlns:ns2", "ns2-value")
        builder.addAttribute("ns2:bar", "bar-ns2-value")
        let elementString: String = builder.build().toXML().toString()

        let parsedElement: StandardExtensionElement = StandardExtensionElementProvider
            .INSTANCE
            .parse(PacketParserUtils.getParserFor(elementString))
        @Assert("foo", parsedElement.getElementName())
        @Assert("ns1-value", parsedElement.getNamespace())
        let barNs2Value: ?String = parsedElement.getAttributeValue("ns2:bar")
        @Assert("bar-ns2-value", barNs2Value)
        let ns2Value: ?String = parsedElement.getAttributeValue("xmlns:ns2")
        @Assert("ns2-value", ns2Value)
    }
}
