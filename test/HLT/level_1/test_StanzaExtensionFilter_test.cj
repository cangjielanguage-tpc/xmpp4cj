// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStanzaExtensionFilter{
    var stanzaExtensionFilter01=StanzaExtensionFilter(None<String>,Mechanisms.NAMESPACE)
    var stanzaExtensionFilter02=StanzaExtensionFilter(None<String>,StanzaErrorTextElement.NAMESPACE)
    var stanzaExtensionFilter03=StanzaExtensionFilter(None<String>,BindFeature.INSTANCE.getNamespace())
    var stanzaExtensionFilter04=StanzaExtensionFilter(None<String>,MessageBody.NAMESPACE)
    var stanzaExtensionFilter05=StanzaExtensionFilter(None<String>,MessageSubject.NAMESPACE)
    var stanzaExtensionFilter06=StanzaExtensionFilter(None<String>,MessageThread.NAMESPACE)
    var stanzaExtensionFilter07=StanzaExtensionFilter(None<String>,SessionFeature.QNAME.getNamespaceURI())
    var stanzaExtensionFilter08=StanzaExtensionFilter(None<String>,StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE)
    var stanzaExtensionFilter09=StanzaExtensionFilter(None<String>,StandardExtensionElement("Standardname","Standardnamespace").getNamespace())

    @TestCase
    func test_StanzaExtensionFilter_test_1(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        stanza01.addExtension(Mechanisms("Mechanisms"))
        stanza01.addExtension(StanzaErrorTextElement("StanzaErrorText","StanzaErrorLang"))
        stanza01.addExtension(BindFeature.INSTANCE)
        stanza01.addExtension(MessageBody("Bodylanguage","Bodymessage"))
        stanza01.addExtension(MessageSubject("subjectlanguage","subjectmessage"))
        stanza01.addExtension(MessageThread("thread","parent"))
        stanza01.addExtension(SessionFeature(true))
        stanza01.addExtension(StanzaError.getBuilder(StanzaErrorCondition.bad_request).build())
        stanza01.addExtension(StandardExtensionElement("Standardname","Standardnamespace"))

        @Assert(stanzaExtensionFilter01.test(stanza01),true)
        @Assert(stanzaExtensionFilter02.test(stanza01),true)
        @Assert(stanzaExtensionFilter03.test(stanza01),true)
        @Assert(stanzaExtensionFilter04.test(stanza01),true)
        @Assert(stanzaExtensionFilter05.test(stanza01),true)
        @Assert(stanzaExtensionFilter06.test(stanza01),true)
        @Assert(stanzaExtensionFilter07.test(stanza01),true)
        @Assert(stanzaExtensionFilter08.test(stanza01),true)
        @Assert(stanzaExtensionFilter09.test(stanza01),true)
    }
    @TestCase
    func test_StanzaExtensionFilter_test_2(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        @Assert(stanzaExtensionFilter01.test(stanza01),false)
        @Assert(stanzaExtensionFilter02.test(stanza01),false)
        @Assert(stanzaExtensionFilter03.test(stanza01),false)
        @Assert(stanzaExtensionFilter04.test(stanza01),false)
        @Assert(stanzaExtensionFilter05.test(stanza01),false)
        @Assert(stanzaExtensionFilter06.test(stanza01),false)
        @Assert(stanzaExtensionFilter07.test(stanza01),false)
        @Assert(stanzaExtensionFilter08.test(stanza01),false)
        @Assert(stanzaExtensionFilter09.test(stanza01),false)
    }
    @TestCase
    func test_StanzaExtensionFilter_test_3(): Unit {
        var stanza02= StanzaBuilder.buildPresence("presence01").build()
        stanza02.addExtension(Mechanisms("Mechanisms"))
        stanza02.addExtension(StanzaErrorTextElement("StanzaErrorText","StanzaErrorLang"))
        stanza02.addExtension(BindFeature.INSTANCE)
        stanza02.addExtension(MessageBody("Bodylanguage","Bodymessage"))
        stanza02.addExtension(MessageSubject("subjectlanguage","subjectmessage"))
        stanza02.addExtension(MessageThread("thread","parent"))
        stanza02.addExtension(SessionFeature(true))
        stanza02.addExtension(StanzaError.getBuilder(StanzaErrorCondition.bad_request).build())
        stanza02.addExtension(StandardExtensionElement("Standardname","Standardnamespace"))
        @Assert(stanzaExtensionFilter01.test(stanza02),true)
        @Assert(stanzaExtensionFilter02.test(stanza02),true)
        @Assert(stanzaExtensionFilter03.test(stanza02),true)
        @Assert(stanzaExtensionFilter04.test(stanza02),true)
        @Assert(stanzaExtensionFilter05.test(stanza02),true)
        @Assert(stanzaExtensionFilter06.test(stanza02),true)
        @Assert(stanzaExtensionFilter07.test(stanza02),true)
        @Assert(stanzaExtensionFilter08.test(stanza02),true)
        @Assert(stanzaExtensionFilter09.test(stanza02),true)
    }
    @TestCase
    func test_StanzaExtensionFilter_test_4(): Unit {
        var stanza02= StanzaBuilder.buildPresence("presence01").build()
        @Assert(stanzaExtensionFilter01.test(stanza02),false)
        @Assert(stanzaExtensionFilter02.test(stanza02),false)
        @Assert(stanzaExtensionFilter03.test(stanza02),false)
        @Assert(stanzaExtensionFilter04.test(stanza02),false)
        @Assert(stanzaExtensionFilter05.test(stanza02),false)
        @Assert(stanzaExtensionFilter06.test(stanza02),false)
        @Assert(stanzaExtensionFilter07.test(stanza02),false)
        @Assert(stanzaExtensionFilter08.test(stanza02),false)
        @Assert(stanzaExtensionFilter09.test(stanza02),false)
    }
    @TestCase
    func test_StanzaExtensionFilter_test_5(): Unit {
        var stanza03= Session()
        stanza03.addExtension(Mechanisms("Mechanisms"))
        stanza03.addExtension(StanzaErrorTextElement("StanzaErrorText","StanzaErrorLang"))
        stanza03.addExtension(BindFeature.INSTANCE)
        stanza03.addExtension(MessageBody("Bodylanguage","Bodymessage"))
        stanza03.addExtension(MessageSubject("subjectlanguage","subjectmessage"))
        stanza03.addExtension(MessageThread("thread","parent"))
        stanza03.addExtension(SessionFeature(true))
        stanza03.addExtension(StanzaError.getBuilder(StanzaErrorCondition.bad_request).build())
        stanza03.addExtension(StandardExtensionElement("Standardname","Standardnamespace"))
        @Assert(stanzaExtensionFilter01.test(stanza03),true)
        @Assert(stanzaExtensionFilter02.test(stanza03),true)
        @Assert(stanzaExtensionFilter03.test(stanza03),true)
        @Assert(stanzaExtensionFilter04.test(stanza03),true)
        @Assert(stanzaExtensionFilter05.test(stanza03),true)
        @Assert(stanzaExtensionFilter06.test(stanza03),true)
        @Assert(stanzaExtensionFilter07.test(stanza03),true)
        @Assert(stanzaExtensionFilter08.test(stanza03),true)
        @Assert(stanzaExtensionFilter09.test(stanza03),true)
    }
    @TestCase
    func test_StanzaExtensionFilter_test_6(): Unit {
        var stanza03= Session()
        @Assert(stanzaExtensionFilter01.test(stanza03),false)
        @Assert(stanzaExtensionFilter02.test(stanza03),false)
        @Assert(stanzaExtensionFilter03.test(stanza03),false)
        @Assert(stanzaExtensionFilter04.test(stanza03),false)
        @Assert(stanzaExtensionFilter05.test(stanza03),false)
        @Assert(stanzaExtensionFilter06.test(stanza03),false)
        @Assert(stanzaExtensionFilter07.test(stanza03),false)
        @Assert(stanzaExtensionFilter08.test(stanza03),false)
        @Assert(stanzaExtensionFilter09.test(stanza03),false)
    }
}
