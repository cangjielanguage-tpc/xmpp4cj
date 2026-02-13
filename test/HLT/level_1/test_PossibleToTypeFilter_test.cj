// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjPossibleToTypeFilter{
     var  stanza01= getStanzaMessageSetTo(None<String>)
     var  stanza02= getStanzaMessageSetTo("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetTo("huawei@w3/index")
     var  stanza04= getStanzaMessageSetTo("huawei@w3")
     var  stanza05= getStanzaMessageSetTo("w3/index")
     var  stanza06= getStanzaMessageSetTo("huawei")
    @TestCase
    func test_PossibleToTypeFilter_test_1(): Unit {
        var possibleToTypeFilter=PossibleToTypeFilter.ENTITY_FULL_JID
        @Assert(possibleToTypeFilter.test(stanza01),false)
        @Assert(possibleToTypeFilter.test(stanza02),false)
        @Assert(possibleToTypeFilter.test(stanza03),true)
        @Assert(possibleToTypeFilter.test(stanza04),false)
        @Assert(possibleToTypeFilter.test(stanza05),false)
        @Assert(possibleToTypeFilter.test(stanza06),false)


    }
    @TestCase
    func test_PossibleToTypeFilter_test_2(): Unit {
        var possibleToTypeFilter=PossibleToTypeFilter.ENTITY_BARE_JID
        @Assert(possibleToTypeFilter.test(stanza01),false)
        @Assert(possibleToTypeFilter.test(stanza02),true)
        @Assert(possibleToTypeFilter.test(stanza03),true)
        @Assert(possibleToTypeFilter.test(stanza04),true)
        @Assert(possibleToTypeFilter.test(stanza05),false)
        @Assert(possibleToTypeFilter.test(stanza06),false)

    }
    @TestCase
    func test_PossibleToTypeFilter_test_3(): Unit {
        var possibleToTypeFilter=PossibleToTypeFilter.DOMAIN_FULL_JID
        @Assert(possibleToTypeFilter.test(stanza01),false)
        @Assert(possibleToTypeFilter.test(stanza02),false)
        @Assert(possibleToTypeFilter.test(stanza03),false)
        @Assert(possibleToTypeFilter.test(stanza04),false)
        @Assert(possibleToTypeFilter.test(stanza05),true)
        @Assert(possibleToTypeFilter.test(stanza06),false)

    }
    @TestCase
    func test_PossibleToTypeFilter_test_4(): Unit {
        var possibleToTypeFilter=PossibleToTypeFilter.DOMAIN_BARE_JID
        @Assert(possibleToTypeFilter.test(stanza01),false)
        @Assert(possibleToTypeFilter.test(stanza02),true)
        @Assert(possibleToTypeFilter.test(stanza03),true)
        @Assert(possibleToTypeFilter.test(stanza04),true)
        @Assert(possibleToTypeFilter.test(stanza05),true)
        @Assert(possibleToTypeFilter.test(stanza06),true)

    }
    @TestCase
    func test_PossibleToTypeFilter_test_5(): Unit {
        var possibleToTypeFilter=PossibleToTypeFilter.TO_ANY_JID
        @Assert(possibleToTypeFilter.test(stanza01),false)
        @Assert(possibleToTypeFilter.test(stanza02),true)
        @Assert(possibleToTypeFilter.test(stanza03),true)
        @Assert(possibleToTypeFilter.test(stanza04),true)
        @Assert(possibleToTypeFilter.test(stanza05),true)
        @Assert(possibleToTypeFilter.test(stanza06),true)

    }
}
