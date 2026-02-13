// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjToMatchesFilter{
     var  stanza01= getStanzaMessageSetTo(None<String>)
     var  stanza02= getStanzaMessageSetTo("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetTo("huawei@w3/index")
     var  stanza04= getStanzaMessageSetTo("huawei@w3")
     var  stanza05= getStanzaMessageSetTo("w3/index")
     var  stanza06= getStanzaMessageSetTo("huawei")
    @TestCase
    func test_ToMatchesFilter_test_1(): Unit {
        var toMatchesFilter=ToMatchesFilter(JidCreate.froms("huawei@w3/index"),true)
        @Assert(toMatchesFilter.test(stanza01),false)
        @Assert(toMatchesFilter.test(stanza02),false)
        @Assert(toMatchesFilter.test(stanza03),true)
        @Assert(toMatchesFilter.test(stanza04),true)
        @Assert(toMatchesFilter.test(stanza05),false)
        @Assert(toMatchesFilter.test(stanza06),false)

    }
    @TestCase
    func test_ToMatchesFilter_test_2(): Unit {
        var toMatchesFilter=ToMatchesFilter(JidCreate.froms("huawei@w3/index"),false)
        @Assert(toMatchesFilter.test(stanza01),false)
        @Assert(toMatchesFilter.test(stanza02),false)
        @Assert(toMatchesFilter.test(stanza03),true)
        @Assert(toMatchesFilter.test(stanza04),false)
        @Assert(toMatchesFilter.test(stanza05),false)
        @Assert(toMatchesFilter.test(stanza06),false)

    }
    @TestCase
    func test_ToMatchesFilter_test_3(): Unit {
        var toMatchesFilter=ToMatchesFilter(None<Jid>,true)
        @Assert(toMatchesFilter.test(stanza01),true)
        @Assert(toMatchesFilter.test(stanza02),false)
        @Assert(toMatchesFilter.test(stanza03),false)
        @Assert(toMatchesFilter.test(stanza04),false)
        @Assert(toMatchesFilter.test(stanza05),false)
        @Assert(toMatchesFilter.test(stanza06),false)

    }
    @TestCase
    func test_ToMatchesFilter_test_4(): Unit {
        var toMatchesFilter=ToMatchesFilter(None<Jid>,true)
        @Assert(toMatchesFilter.test(stanza01),true)
        @Assert(toMatchesFilter.test(stanza02),false)
        @Assert(toMatchesFilter.test(stanza03),false)
        @Assert(toMatchesFilter.test(stanza04),false)
        @Assert(toMatchesFilter.test(stanza05),false)
        @Assert(toMatchesFilter.test(stanza06),false)

    }
}
