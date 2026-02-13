// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_addExtension_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.getExtensions().size,0)
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        let extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        iqData.addExtension(extensionElement01)
        iqData.addExtension(extensionElement02)
        iqData.addExtension(extensionElement03)
        @Assert(iqData.getExtensions().size,3)
        @Assert(iqData.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(iqData.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(iqData.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(iqData.getExtensions().get(2).getOrThrow().getElementName(),"name03")
    }
    @TestCase
    func test_IqData_addOptExtensions_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        iqData.addOptExtensions(None<Collection< ExtensionElement >>)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        @Assert(iqData.getExtensions().size,0)
   }
    @TestCase
    func test_IqData_addOptExtensions_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        iqData.addOptExtensions([])
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        @Assert(iqData.getExtensions().size,0)
   }
    @TestCase
    func test_IqData_addOptExtensions_03(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.getExtensions().size,0)
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        let extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        let actIqData=iqData.addOptExtensions([extensionElement01,extensionElement02,extensionElement03])
        @Assert(iqData.getExtensions().size,3)
        @Assert(iqData.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(iqData.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(iqData.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(iqData.getExtensions().get(2).getOrThrow().getElementName(),"name03")
   }
    @TestCase
    func test_IqData_addExtensions_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.getExtensions().size,0)
        iqData.addExtensions([])
        @Assert(iqData.getExtensions().size,0)
   }
    @TestCase
    func test_IqData_addExtensions_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.getExtensions().size,0)
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        let extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        iqData.addExtensions([extensionElement01,extensionElement02,extensionElement03])
        @Assert(iqData.getExtensions().size,3)
        @Assert(iqData.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(iqData.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(iqData.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(iqData.getExtensions().get(2).getOrThrow().getElementName(),"name03")
   }
}