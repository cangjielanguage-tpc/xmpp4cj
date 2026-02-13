// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjPossibleFromTypeFilter{
     var  stanza01= getStanzaMessageSetFrom(None<String>)
     var  stanza02= getStanzaMessageSetFrom("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetFrom("huawei@w3/index")
     var  stanza04= getStanzaMessageSetFrom("huawei@w3")
     var  stanza05= getStanzaMessageSetFrom("w3/index")
     var  stanza06= getStanzaMessageSetFrom("huawei")
    @TestCase
    func test_PossibleFromTypeFilter_test_1(): Unit {
        var possibleFromTypeFilter=PossibleFromTypeFilter.ENTITY_FULL_JID
        @Assert(possibleFromTypeFilter.test(stanza01),false)
        @Assert(possibleFromTypeFilter.test(stanza02),false)
        @Assert(possibleFromTypeFilter.test(stanza03),true)
        @Assert(possibleFromTypeFilter.test(stanza04),false)
        @Assert(possibleFromTypeFilter.test(stanza05),false)
        @Assert(possibleFromTypeFilter.test(stanza06),false)


    }
    @TestCase
    func test_PossibleFromTypeFilter_test_2(): Unit {
        var possibleFromTypeFilter=PossibleFromTypeFilter.ENTITY_BARE_JID
        @Assert(possibleFromTypeFilter.test(stanza01),false)
        @Assert(possibleFromTypeFilter.test(stanza02),true)
        @Assert(possibleFromTypeFilter.test(stanza03),true)
        @Assert(possibleFromTypeFilter.test(stanza04),true)
        @Assert(possibleFromTypeFilter.test(stanza05),false)
        @Assert(possibleFromTypeFilter.test(stanza06),false)

    }
    @TestCase
    func test_PossibleFromTypeFilter_test_3(): Unit {
        var possibleFromTypeFilter=PossibleFromTypeFilter.DOMAIN_FULL_JID
        @Assert(possibleFromTypeFilter.test(stanza01),false)
        @Assert(possibleFromTypeFilter.test(stanza02),false)
        @Assert(possibleFromTypeFilter.test(stanza03),false)
        @Assert(possibleFromTypeFilter.test(stanza04),false)
        @Assert(possibleFromTypeFilter.test(stanza05),true)
        @Assert(possibleFromTypeFilter.test(stanza06),false)

    }
    @TestCase
    func test_PossibleFromTypeFilter_test_4(): Unit {
        var possibleFromTypeFilter=PossibleFromTypeFilter.DOMAIN_BARE_JID
        @Assert(possibleFromTypeFilter.test(stanza01),false)
        @Assert(possibleFromTypeFilter.test(stanza02),true)
        @Assert(possibleFromTypeFilter.test(stanza03),true)
        @Assert(possibleFromTypeFilter.test(stanza04),true)
        @Assert(possibleFromTypeFilter.test(stanza05),true)
        @Assert(possibleFromTypeFilter.test(stanza06),true)

    }
    @TestCase
    func test_PossibleFromTypeFilter_test_5(): Unit {
        var possibleFromTypeFilter=PossibleFromTypeFilter.FROM_ANY_JID
        @Assert(possibleFromTypeFilter.test(stanza01),false)
        @Assert(possibleFromTypeFilter.test(stanza02),true)
        @Assert(possibleFromTypeFilter.test(stanza03),true)
        @Assert(possibleFromTypeFilter.test(stanza04),true)
        @Assert(possibleFromTypeFilter.test(stanza05),true)
        @Assert(possibleFromTypeFilter.test(stanza06),true)

    }
}
