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
    func test_OrFilter_test_1(): Unit {
        var fromMatchesFilter=FromMatchesFilter(JidCreate.froms("huawei@w3/index"),true)
        var fromTypeFilter=FromTypeFilter.ENTITY_FULL_JID
        var possibleFromTypeFilter=PossibleFromTypeFilter.ENTITY_FULL_JID
        var orFilter=OrFilter([fromMatchesFilter,fromTypeFilter,possibleFromTypeFilter])
        @Assert(orFilter.test(stanza01),false)
        @Assert(orFilter.test(stanza02),false)
        @Assert(orFilter.test(stanza03),true)
        @Assert(orFilter.test(stanza04),true)
        @Assert(orFilter.test(stanza05),false)
        @Assert(orFilter.test(stanza06),false)
    }
    @TestCase
    func test_OrFilter_test_2(): Unit {
        var orFilter=OrFilter()
        @Assert(orFilter.test(stanza01),false)
        @Assert(orFilter.test(stanza02),false)
        @Assert(orFilter.test(stanza03),false)
        @Assert(orFilter.test(stanza04),false)
        @Assert(orFilter.test(stanza05),false)
        @Assert(orFilter.test(stanza06),false)
    }
    @TestCase
    func test_OrFilter_test_3(): Unit {
        var fromMatchesFilter=FromMatchesFilter(JidCreate.froms("huawei@w3/index"),true)
        var orFilter=OrFilter([fromMatchesFilter])
        @Assert(orFilter.test(stanza01),false)
        @Assert(orFilter.test(stanza02),false)
        @Assert(orFilter.test(stanza03),true)
        @Assert(orFilter.test(stanza04),true)
        @Assert(orFilter.test(stanza05),false)
        @Assert(orFilter.test(stanza06),false)
    }
}
