// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjMessageBuilder {
    @TestCase
    func test_MessageBuilder_overrideExtension_01(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var allElement = msgBuilder.getExtensions()
        @Assert(allElement.size,0)
        let extensionElement01 = StandardExtensionElement("name01", "namespace01")
        let extensionElement02 = StandardExtensionElement("name02", "namespace02")
        let extensionElement03 = StandardExtensionElement("name03", "namespace03")
        msgBuilder.addExtensions([extensionElement01, extensionElement02, extensionElement03])
        let extensionElement04 = StandardExtensionElement("name04", "namespace04")
        msgBuilder.overrideExtension(extensionElement04)
        allElement = msgBuilder.getExtensions()
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
    func test_MessageBuilder_overrideExtension_02(): Unit {
        let stanzaId = Some("MessageStanzaId")
        var msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        var allElement = msgBuilder.getExtensions()
        @Assert(allElement.size,0)
        let extensionElement01 = StandardExtensionElement("name01", "namespace01")
        var extensionElement02 = StandardExtensionElement("name02", "namespace02")
        let extensionElement03 = StandardExtensionElement("name03", "namespace03")
        msgBuilder.addExtensions([extensionElement01, extensionElement02, extensionElement03])
        extensionElement02 = StandardExtensionElement("name02", "namespace05")
        msgBuilder.overrideExtension(extensionElement02)
        allElement = msgBuilder.getExtensions()
        @Assert(allElement.size,4)
        @Assert(allElement.get(0).getOrThrow().getNamespace(),"namespace01")
        @Assert(allElement.get(1).getOrThrow().getNamespace(),"namespace02")
        @Assert(allElement.get(2).getOrThrow().getNamespace(),"namespace03")
        @Assert(allElement.get(3).getOrThrow().getNamespace(),"namespace05")
        @Assert(allElement.get(0).getOrThrow().getElementName(),"name01")
        @Assert(allElement.get(1).getOrThrow().getElementName(),"name02")
        @Assert(allElement.get(2).getOrThrow().getElementName(),"name03")
        @Assert(allElement.get(3).getOrThrow().getElementName(),"name02")
    }
}
