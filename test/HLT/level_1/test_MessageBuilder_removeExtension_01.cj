// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_removeExtension01_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        msgBuilder.addExtensions([extensionElement03])
        var allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,1)
        msgBuilder.removeExtension(extensionElement03)
        allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,0)
  }
    @TestCase
    func test_MessageBuilder_removeExtension01_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        msgBuilder.addExtensions([extensionElement01])
        var allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,1)
        var extensionElement02=StandardExtensionElement("name02","namespace02")
        msgBuilder.removeExtension(extensionElement02)
        allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,1)
        @Assert(allElement.get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(allElement.get(0).getOrThrow().getElementName(),"name01")
   }
    @TestCase
    func test_MessageBuilder_removeExtension02_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let extensionElement03=StandardExtensionElement("name03","namespace03")
        msgBuilder.addExtensions([extensionElement03])
        var allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,1)
        msgBuilder.removeExtension("name03","namespace03")
        allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,0)
  }
    @TestCase
    func test_MessageBuilder_removeExtension02_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let extensionElement01=StandardExtensionElement("name01","namespace01")
        msgBuilder.addExtensions([extensionElement01])
        var allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,1)
        var extensionElement02=StandardExtensionElement("name02","namespace02")
        msgBuilder.removeExtension("name02","namespace02")
        allElement=msgBuilder.getExtensions()
        @Assert(allElement.size,1)
        @Assert(allElement.get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(allElement.get(0).getOrThrow().getElementName(),"name01")
   }
}