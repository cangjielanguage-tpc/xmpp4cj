// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjNotFilter{
    @TestCase
    func test_NotFilter_test_1(): Unit {
        var  stanza01= getStanzaMessageSetFrom(None<String>)
        var  stanza02= getStanzaMessageSetFrom("test_account@jabber.org")
        var  stanza03= getStanzaMessageSetFrom("huawei@w3/index")
        var  stanza04= getStanzaMessageSetFrom("huawei@w3")
        var  stanza05= getStanzaMessageSetFrom("w3/index")
        var  stanza06= getStanzaMessageSetFrom("huawei")
        var emptyToMatcher=EmptyToMatcher.INSTANCE
        var notFilter=NotFilter(emptyToMatcher)
        @Assert(notFilter.test(stanza01),false)
        @Assert(notFilter.test(stanza02),false)
        @Assert(notFilter.test(stanza03),false)
        @Assert(notFilter.test(stanza04),false)
        @Assert(notFilter.test(stanza05),false)
        @Assert(notFilter.test(stanza06),false)
    }
    @TestCase
    func test_NotFilter_test_2(): Unit {
        var  stanza01= getStanzaMessageSetTo(None<String>)
        var  stanza02= getStanzaMessageSetTo("test_account@jabber.org")
        var  stanza03= getStanzaMessageSetTo("huawei@w3/index")
        var  stanza04= getStanzaMessageSetTo("huawei@w3")
        var  stanza05= getStanzaMessageSetTo("w3/index")
        var  stanza06= getStanzaMessageSetTo("huawei")
        var emptyToMatcher=EmptyToMatcher.INSTANCE
        var notFilter=NotFilter(emptyToMatcher)
        @Assert(notFilter.test(stanza01),false)
        @Assert(notFilter.test(stanza02),true)
        @Assert(notFilter.test(stanza03),true)
        @Assert(notFilter.test(stanza04),true)
        @Assert(notFilter.test(stanza05),true)
        @Assert(notFilter.test(stanza06),true)
    }
}
