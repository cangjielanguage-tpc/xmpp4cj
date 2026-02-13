// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStanzaIdFilter{
    var stanza01= StanzaBuilder.buildMessage("message01").build();
    var stanza02= StanzaBuilder.buildPresence("presence01").build();
    var stanza03= Session()
    var stanza04= Bind.newSet(Resourcepart.fromOrNull("resource"))
    var stanza05=EmptyResultIQ()
    var stanzaErrorBuilder= StanzaError.froms(StanzaErrorCondition.forbidden,"StanzaErrorBuilder_me")
    var stanza06=ErrorIQ.builder(stanzaErrorBuilder.build()).build()
    var stanza07=UnparsedIQ("UnparsedIQelement","UnparsedIQnamespace","UnparsedIQcontent")

    @TestCase
    func test_StanzaIdFilter_test_1(): Unit {
        var stanzaIdFilter01=StanzaIdFilter("presence01")
        @Assert(stanzaIdFilter01.test(stanza01),false)
        @Assert(stanzaIdFilter01.test(stanza02),true)
        @Assert(stanzaIdFilter01.test(stanza03),false)
        @Assert(stanzaIdFilter01.test(stanza04),false)
        @Assert(stanzaIdFilter01.test(stanza05),false)
        @Assert(stanzaIdFilter01.test(stanza06),false)
        @Assert(stanzaIdFilter01.test(stanza07),false)
    }
    @TestCase
    func test_StanzaIdFilter_test_2(): Unit {
        var stanzaIdFilter02=StanzaIdFilter(stanza01)
        @Assert(stanzaIdFilter02.test(stanza01),true)
        @Assert(stanzaIdFilter02.test(stanza02),false)
        @Assert(stanzaIdFilter02.test(stanza03),false)
        @Assert(stanzaIdFilter02.test(stanza04),false)
        @Assert(stanzaIdFilter02.test(stanza05),false)
        @Assert(stanzaIdFilter02.test(stanza06),false)
        @Assert(stanzaIdFilter02.test(stanza07),false)
    }
    @TestCase
    func test_StanzaIdFilter_test_3(): Unit {
        var stanzaIdFilter03=StanzaIdFilter(stanza03.getStanzaId())
        @Assert(stanzaIdFilter03.test(stanza03),true)
    }
    @TestCase
    func test_StanzaIdFilter_test_4(): Unit {
        var stanzaIdFilter04=StanzaIdFilter(stanza04.getStanzaId())
        @Assert(stanzaIdFilter04.test(stanza04),true)
    }
    @TestCase
    func test_StanzaIdFilter_test_5(): Unit {
        var stanzaIdFilter05=StanzaIdFilter(stanza05.getStanzaId())
        @Assert(stanzaIdFilter05.test(stanza05),true)
    }
    @TestCase
    func test_StanzaIdFilter_test_6(): Unit {
        var stanzaIdFilter06=StanzaIdFilter(stanza06.getStanzaId())
        @Assert(stanzaIdFilter06.test(stanza06),true)
    }
    @TestCase
    func test_StanzaIdFilter_test_7(): Unit {
        var stanzaIdFilter07=StanzaIdFilter(stanza07.getStanzaId())
        @Assert(stanzaIdFilter07.test(stanza07),true)
    }
}
