// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjFromMatchesFilter{
     var  stanza01= getStanzaMessageSetFrom(None<String>)
     var  stanza02= getStanzaMessageSetFrom("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetFrom("huawei@w3/index")
     var  stanza04= getStanzaMessageSetFrom("huawei@w3")
     var  stanza05= getStanzaMessageSetFrom("w3/index")
     var  stanza06= getStanzaMessageSetFrom("huawei")
    @TestCase
    func test_FromMatchesFilter_test_1(): Unit {
        var fromMatchesFilter=FromMatchesFilter(JidCreate.froms("huawei@w3/index"),true)
        @Assert(fromMatchesFilter.test(stanza01),false)
        @Assert(fromMatchesFilter.test(stanza02),false)
        @Assert(fromMatchesFilter.test(stanza03),true)
        @Assert(fromMatchesFilter.test(stanza04),true)
        @Assert(fromMatchesFilter.test(stanza05),false)
        @Assert(fromMatchesFilter.test(stanza06),false)


    }
    @TestCase
    func test_FromMatchesFilter_test_2(): Unit {
        var fromMatchesFilter=FromMatchesFilter(JidCreate.froms("huawei@w3/index"),false)
        @Assert(fromMatchesFilter.test(stanza01),false)
        @Assert(fromMatchesFilter.test(stanza02),false)
        @Assert(fromMatchesFilter.test(stanza03),true)
        @Assert(fromMatchesFilter.test(stanza04),false)
        @Assert(fromMatchesFilter.test(stanza05),false)
        @Assert(fromMatchesFilter.test(stanza06),false)

    }
    @TestCase
    func test_FromMatchesFilter_test_3(): Unit {
        var fromMatchesFilter=FromMatchesFilter(None<Jid>,true)
        @Assert(fromMatchesFilter.test(stanza01),true)
        @Assert(fromMatchesFilter.test(stanza02),false)
        @Assert(fromMatchesFilter.test(stanza03),false)
        @Assert(fromMatchesFilter.test(stanza04),false)
        @Assert(fromMatchesFilter.test(stanza05),false)
        @Assert(fromMatchesFilter.test(stanza06),false)

    }
    @TestCase
    func test_FromMatchesFilter_test_4(): Unit {
        var fromMatchesFilter=FromMatchesFilter(None<Jid>,true)
        @Assert(fromMatchesFilter.test(stanza01),true)
        @Assert(fromMatchesFilter.test(stanza02),false)
        @Assert(fromMatchesFilter.test(stanza03),false)
        @Assert(fromMatchesFilter.test(stanza04),false)
        @Assert(fromMatchesFilter.test(stanza05),false)
        @Assert(fromMatchesFilter.test(stanza06),false)

    }
}
