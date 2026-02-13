// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStandardExtensionElement{
    var name="name"
    var namespace="namespace"
    var standardExtensionElement=StandardExtensionElement(name,namespace)
    @TestCase
    func test_StandardExtensionElement_allFunc01_01_1(): Unit {
        name="name"
        namespace="namespace"
        standardExtensionElement=StandardExtensionElement(name,namespace)
        @Assert(standardExtensionElement.getElementName(),"name")
        @Assert(standardExtensionElement.getNamespace(),"namespace")
        @Assert(standardExtensionElement.getAttributeValue("attribute").isNone(),true)
        @Assert(standardExtensionElement.getAttributes().size,0)
        @Assert(standardExtensionElement.getFirstElement("element","namespace").isNone(),true)
        @Assert(standardExtensionElement.getFirstElement("element").isNone(),true)
        @Assert(standardExtensionElement.getElements("element","namespace").isNone(),true)
        @Assert(standardExtensionElement.getElements("element").isNone(),true)
        @Assert(standardExtensionElement.getElements().size,0)
        @Assert(standardExtensionElement.getText().isNone(),true)
        @Assert(standardExtensionElement.toXML().toString(),"<name xmlns='namespace'></name>")
        @Assert(standardExtensionElement==standardExtensionElement,true)
        var standardExtensionElement_tmp=StandardExtensionElement.builder("name","namespace").build()
        @Assert(standardExtensionElement_tmp==standardExtensionElement,false)
        standardExtensionElement_tmp=StandardExtensionElement.builder("","namespace").build()
        @Assert(standardExtensionElement_tmp==standardExtensionElement,false)
    }
    @TestCase
    func test_StandardExtensionElement_allFunc01_01_2(): Unit {
        name=""
        namespace=""
        standardExtensionElement=StandardExtensionElement(name,namespace)
        @Assert(standardExtensionElement.getElementName(),"")
        @Assert(standardExtensionElement.getNamespace(),"")
        @Assert(standardExtensionElement.getAttributeValue("").isNone(),true)
        @Assert(standardExtensionElement.getAttributes().size,0)
        @Assert(standardExtensionElement.getFirstElement("","").isNone(),true)
        @Assert(standardExtensionElement.getFirstElement("").isNone(),true)
        @Assert(standardExtensionElement.getElements("","").isNone(),true)
        @Assert(standardExtensionElement.getElements("").isNone(),true)
        @Assert(standardExtensionElement.getElements().size,0)
        @Assert(standardExtensionElement.getText().isNone(),true)
        @Assert(standardExtensionElement.toXML().toString(),"<></>")
    }
    @TestCase
    func test_StandardExtensionElement_allFunc01_01_3(): Unit {
        name=" "
        namespace=" "
        standardExtensionElement=StandardExtensionElement(name,namespace)
        @Assert(standardExtensionElement.getElementName()," ")
        @Assert(standardExtensionElement.getNamespace()," ")
        @Assert(standardExtensionElement.getAttributeValue(" ").isNone(),true)
        @Assert(standardExtensionElement.getAttributes().size,0)
        @Assert(standardExtensionElement.getFirstElement(" "," ").isNone(),true)
        @Assert(standardExtensionElement.getFirstElement(" ").isNone(),true)
        @Assert(standardExtensionElement.getElements(" "," ").isNone(),true)
        @Assert(standardExtensionElement.getElements(" ").isNone(),true)
        @Assert(standardExtensionElement.getElements().size,0)
        @Assert(standardExtensionElement.getText().isNone(),true)
        @Assert(standardExtensionElement.toXML().toString(),"<  xmlns=' '></ >")

    }
    @TestCase
    func test_StandardExtensionElement_builder_1(): Unit {
        var standardExtensionElement_tmp=StandardExtensionElement.builder("name","namespace").build()
        @Assert(standardExtensionElement_tmp.toXML().toString(),"<name xmlns='namespace'></name>")
    }
    @TestCase
    func test_StandardExtensionElement_builder_2(): Unit {
        var standardExtensionElement_tmp=StandardExtensionElement.builder("","").build()
        @Assert(standardExtensionElement_tmp.toXML().toString(),"<></>")
    }
    @TestCase
    func test_StandardExtensionElement_builder_3(): Unit {
        var standardExtensionElement_tmp=StandardExtensionElement.builder(" "," ").build()
        @Assert(standardExtensionElement_tmp.toXML().toString(),"<  xmlns=' '></ >")
    }
}
