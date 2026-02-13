// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_overrideExtension_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        let extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        let actIqData=iqData.addExtensions([extensionElement01,extensionElement02,extensionElement03])
        let extensionElement04=StandardExtensionElement("name04","namespace04")
        actIqData.overrideExtension(extensionElement04)
        let allElement=actIqData.getExtensions()
        @Assert(allElement.size,4)
        @Assert(allElement.get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(allElement.get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(allElement.get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(allElement.get(3).getOrThrow().getNamespace(),"namespace04")
        @Assert(allElement.get(0).getOrThrow().getElementName(),"name01")
        @Assert(allElement.get(1).getOrThrow().getElementName(),"name02")
        @Assert(allElement.get(2).getOrThrow().getElementName(),"name03")
        @Assert(allElement.get(3).getOrThrow().getElementName(),"name04")
    }
    @TestCase
    func test_IqData_overrideExtension_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        @Assert(iqData.toString(),"StanzaBuilder(id='IqDataStanzaId' type='get')")
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        var extensionElement02=StandardExtensionElement("name02","namespace02")
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        let actIqData=iqData.addExtensions([extensionElement01,extensionElement02,extensionElement03])
        extensionElement02=StandardExtensionElement("name02","namespace05")
        actIqData.overrideExtension(extensionElement02)
        let allElement=actIqData.getExtensions()
        @Assert(allElement.size,4)
        @Assert(allElement.get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(allElement.get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(allElement.get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(allElement.get(3).getOrThrow().getNamespace(),"namespace05")
        @Assert(allElement.get(0).getOrThrow().getElementName(),"name01")
        @Assert(allElement.get(1).getOrThrow().getElementName(),"name02")
        @Assert(allElement.get(2).getOrThrow().getElementName(),"name03")
        @Assert(allElement.get(3).getOrThrow().getElementName(),"name02")   }
}