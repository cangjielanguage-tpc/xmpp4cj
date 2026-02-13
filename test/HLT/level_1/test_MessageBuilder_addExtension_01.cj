// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder {
    @TestCase
    func test_MessageBuilder_addExtension_01(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var actMsg = msgBuilder.build()
         @Assert(actMsg.getExtensions().size,0)
        let extensionElement01 = StandardExtensionElement("name01", "namespace01")
        let extensionElement02 = StandardExtensionElement("name02", "namespace02")
        let extensionElement03 = StandardExtensionElement("name03", "namespace03")
        msgBuilder.addExtension(extensionElement01)
        msgBuilder.addExtension(extensionElement02)
        msgBuilder.addExtension(extensionElement03)
        actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,3)
        @Assert(actMsg.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(actMsg.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(actMsg.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(actMsg.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(actMsg.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(actMsg.getExtensions().get(2).getOrThrow().getElementName(),"name03")
    }
    @TestCase
    func test_MessageBuilder_addOptExtensions_01(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
        msgBuilder.addOptExtensions(None<Collection<ExtensionElement>>)
        actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
    }
    @TestCase
    func test_MessageBuilder_addOptExtensions_02(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
        msgBuilder.addOptExtensions([])
        actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
    }
    @TestCase
    func test_MessageBuilder_addOptExtensions_03(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
        let extensionElement01 = StandardExtensionElement("name01", "namespace01")
        let extensionElement02 = StandardExtensionElement("name02", "namespace02")
        let extensionElement03 = StandardExtensionElement("name03", "namespace03")
        msgBuilder.addOptExtensions([extensionElement01, extensionElement02, extensionElement03])
        actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,3)
        @Assert(actMsg.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(actMsg.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(actMsg.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(actMsg.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(actMsg.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(actMsg.getExtensions().get(2).getOrThrow().getElementName(),"name03")
    }
    @TestCase
    func test_MessageBuilder_addExtensions_01(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
        msgBuilder.addExtensions([])
        actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
    }
    @TestCase
    func test_MessageBuilder_addExtensions_02(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,0)
        let extensionElement01 = StandardExtensionElement("name01", "namespace01")
        let extensionElement02 = StandardExtensionElement("name02", "namespace02")
        let extensionElement03 = StandardExtensionElement("name03", "namespace03")
        msgBuilder.addExtensions([extensionElement01, extensionElement02, extensionElement03])
        actMsg = msgBuilder.build()
        @Assert(actMsg.getExtensions().size,3)
        @Assert(actMsg.getExtensions().get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(actMsg.getExtensions().get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(actMsg.getExtensions().get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(actMsg.getExtensions().get(0).getOrThrow().getElementName(),"name01")
        @Assert(actMsg.getExtensions().get(1).getOrThrow().getElementName(),"name02")
        @Assert(actMsg.getExtensions().get(2).getOrThrow().getElementName(),"name03")
    }
}
