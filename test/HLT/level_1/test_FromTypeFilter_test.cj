// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjFromTypeFilter{
     var  stanza01= getStanzaMessageSetFrom(None<String>)
     var  stanza02= getStanzaMessageSetFrom("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetFrom("huawei@w3/index")
     var  stanza04= getStanzaMessageSetFrom("huawei@w3")
     var  stanza05= getStanzaMessageSetFrom("w3/index")
     var  stanza06= getStanzaMessageSetFrom("huawei")

    @TestCase
    func test_FromTypeFilter_test_1(): Unit {
        var fromTypeFilter=FromTypeFilter.ENTITY_FULL_JID
        @Assert(fromTypeFilter.test(stanza01),false)
        @Assert(fromTypeFilter.test(stanza02),false)
        @Assert(fromTypeFilter.test(stanza03),true)
        @Assert(fromTypeFilter.test(stanza04),false)
        @Assert(fromTypeFilter.test(stanza05),false)
        @Assert(fromTypeFilter.test(stanza06),false)
    }
    @TestCase
    func test_FromTypeFilter_test_2(): Unit {
        var fromTypeFilter=FromTypeFilter.ENTITY_BARE_JID
        @Assert(fromTypeFilter.test(stanza01),false)
        @Assert(fromTypeFilter.test(stanza02),true)
        @Assert(fromTypeFilter.test(stanza03),false)
        @Assert(fromTypeFilter.test(stanza04),true)
        @Assert(fromTypeFilter.test(stanza05),false)
        @Assert(fromTypeFilter.test(stanza06),false)
    }
    @TestCase
    func test_FromTypeFilter_test_3(): Unit {
        var fromTypeFilter=FromTypeFilter.DOMAIN_FULL_JID
        @Assert(fromTypeFilter.test(stanza01),false)
        @Assert(fromTypeFilter.test(stanza02),false)
        @Assert(fromTypeFilter.test(stanza03),false)
        @Assert(fromTypeFilter.test(stanza04),false)
        @Assert(fromTypeFilter.test(stanza05),true)
        @Assert(fromTypeFilter.test(stanza06),false)
    }
    @TestCase
    func test_FromTypeFilter_test_4(): Unit {
        var fromTypeFilter=FromTypeFilter.DOMAIN_BARE_JID
        @Assert(fromTypeFilter.test(stanza01),false)
        @Assert(fromTypeFilter.test(stanza02),false)
        @Assert(fromTypeFilter.test(stanza03),false)
        @Assert(fromTypeFilter.test(stanza04),false)
        @Assert(fromTypeFilter.test(stanza05),false)
        @Assert(fromTypeFilter.test(stanza06),true)
    }
    @TestCase
    func test_FromTypeFilter_test_5(): Unit {
        var fromTypeFilter=FromTypeFilter.FROM_ANY_JID
        @Assert(fromTypeFilter.test(stanza01),false)
        @Assert(fromTypeFilter.test(stanza02),true)
        @Assert(fromTypeFilter.test(stanza03),true)
        @Assert(fromTypeFilter.test(stanza04),true)
        @Assert(fromTypeFilter.test(stanza05),true)
        @Assert(fromTypeFilter.test(stanza06),true)
    }
}
