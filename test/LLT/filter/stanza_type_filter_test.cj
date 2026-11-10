// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStanzaTypeFilter {
    var stanza01 = StanzaBuilder.buildMessage("message01").build();
    var stanza02 = StanzaBuilder.buildPresence("presence01").build();
    var stanza03 = Session()
    var stanza04 = Bind.newSet(Resourcepart.fromOrNull("resource"))
    var stanza05 = EmptyResultIQ()
    var stanzaErrorBuilder = StanzaError.froms(StanzaErrorCondition.forbidden, "StanzaErrorBuilder_me")
    var stanza06 = ErrorIQ.builder(stanzaErrorBuilder.build()).build()
    var stanza07 = UnparsedIQ("UnparsedIQelement", "UnparsedIQnamespace", "UnparsedIQcontent")

    @TestCase
    func test_StanzaTypeFilter_test_1(): Unit {
        var stanzaIdFilter01 = StanzaTypeFilter<Presence>.PRESENCE
        @Assert(stanzaIdFilter01.test(stanza01),false)
        @Assert(stanzaIdFilter01.test(stanza02),true)
        @Assert(stanzaIdFilter01.test(stanza03),false)
        @Assert(stanzaIdFilter01.test(stanza04),false)
        @Assert(stanzaIdFilter01.test(stanza05),false)
        @Assert(stanzaIdFilter01.test(stanza06),false)
        @Assert(stanzaIdFilter01.test(stanza07),false)
    }

    @TestCase
    func test_StanzaTypeFilter_test_2(): Unit {
        var stanzaIdFilter02 = StanzaTypeFilter<Message>.MESSAGE
        @Assert(stanzaIdFilter02.test(stanza01),true)
        @Assert(stanzaIdFilter02.test(stanza02),false)
        @Assert(stanzaIdFilter02.test(stanza03),false)
        @Assert(stanzaIdFilter02.test(stanza04),false)
        @Assert(stanzaIdFilter02.test(stanza05),false)
        @Assert(stanzaIdFilter02.test(stanza06),false)
        @Assert(stanzaIdFilter02.test(stanza07),false)
    }

    @TestCase
    func test_StanzaTypeFilter_test_3(): Unit {
        var stanzaIdFilter03 = StanzaTypeFilter<IQ>.IQ
        @Assert(stanzaIdFilter03.test(stanza01),false)
        @Assert(stanzaIdFilter03.test(stanza02),false)
        @Assert(stanzaIdFilter03.test(stanza03),true)
        @Assert(stanzaIdFilter03.test(stanza04),true)
        @Assert(stanzaIdFilter03.test(stanza05),true)
        @Assert(stanzaIdFilter03.test(stanza06),true)
        @Assert(stanzaIdFilter03.test(stanza07),true)
    }
}
