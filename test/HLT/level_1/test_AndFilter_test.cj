// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjAndFilter{
     var  stanza01= getStanzaMessageSetFrom(None<String>)
     var  stanza02= getStanzaMessageSetFrom("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetFrom("huawei@w3/index")
     var  stanza04= getStanzaMessageSetFrom("huawei@w3")
     var  stanza05= getStanzaMessageSetFrom("w3/index")
     var  stanza06= getStanzaMessageSetFrom("huawei")
    @TestCase
    func test_AndFilter_test_1(): Unit {
        var fromMatchesFilter=FromMatchesFilter(JidCreate.froms("huawei@w3/index"),true)
        var fromTypeFilter=FromTypeFilter.ENTITY_FULL_JID
        var possibleFromTypeFilter=PossibleFromTypeFilter.ENTITY_FULL_JID
        var andFilter=AndFilter([fromMatchesFilter,fromTypeFilter,possibleFromTypeFilter])
        @Assert(andFilter.test(stanza01),false)
        @Assert(andFilter.test(stanza02),false)
        @Assert(andFilter.test(stanza03),true)
        @Assert(andFilter.test(stanza04),false)
        @Assert(andFilter.test(stanza05),false)
        @Assert(andFilter.test(stanza06),false)
    }
    @TestCase
    func test_AndFilter_test_2(): Unit {
        var andFilter=AndFilter()
        @Assert(andFilter.test(stanza01),true)
        @Assert(andFilter.test(stanza02),true)
        @Assert(andFilter.test(stanza03),true)
        @Assert(andFilter.test(stanza04),true)
        @Assert(andFilter.test(stanza05),true)
        @Assert(andFilter.test(stanza06),true)
    }
    @TestCase
    func test_AndFilter_test_3(): Unit {
        var fromMatchesFilter=FromMatchesFilter(JidCreate.froms("huawei@w3/index"),true)
        var andFilter=AndFilter([fromMatchesFilter])
        @Assert(andFilter.test(stanza01),false)
        @Assert(andFilter.test(stanza02),false)
        @Assert(andFilter.test(stanza03),true)
        @Assert(andFilter.test(stanza04),true)
        @Assert(andFilter.test(stanza05),false)
        @Assert(andFilter.test(stanza06),false)
    }
}
