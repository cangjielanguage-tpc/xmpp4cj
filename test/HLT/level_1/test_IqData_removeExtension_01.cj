// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_removeExtension01_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        let extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        let actIqData=iqData.addExtensions([extensionElement01,extensionElement02,extensionElement03])
        @Assert(actIqData.getExtensions().size,3)
        let extensionElement04=StandardExtensionElement("name04","namespace04")
        actIqData.removeExtension(extensionElement04)
        @Assert(actIqData.getExtensions().size,3)
        @Assert(actIqData.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(actIqData.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(actIqData.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(actIqData.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(actIqData.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(actIqData.getExtensions().get(2).getOrThrow().getElementName(),"name03")
    }
    @TestCase
    func test_IqData_removeExtension01_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        var extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        iqData.addExtensions([extensionElement01,extensionElement02,extensionElement03])
        @Assert(iqData.getExtensions().size,3)
        iqData.removeExtension(extensionElement02)
        @Assert(iqData.getExtensions().size,2)
        @Assert(iqData.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getNamespace(),"namespace03")
        @Assert(iqData.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(iqData.getExtensions().get(1).getOrThrow().getElementName(),"name03")

   }
    @TestCase
    func test_IqData_removeExtension02_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        iqData.addExtensions([extensionElement03])
        var allElement=iqData.getExtensions()
        @Assert(allElement.size,1)
        iqData.removeExtension("name03","namespace03")
        allElement=iqData.getExtensions()
        @Assert(allElement.size,0)
  }
    @TestCase
    func test_IqData_removeExtension02_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        iqData.addExtensions([extensionElement01])
        var allElement=iqData.getExtensions()
        @Assert(allElement.size,1)
        var extensionElement02=StandardExtensionElement("name02","namespace02")
        iqData.removeExtension("name02","namespace02")
        allElement=iqData.getExtensions()
        @Assert(allElement.size,1)
        @Assert(allElement.get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(allElement.get(0).getOrThrow().getElementName(),"name01")
   }
}