// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjToTypeFilter{
     var  stanza01= getStanzaMessageSetTo(None<String>)
     var  stanza02= getStanzaMessageSetTo("test_account@jabber.org")
     var  stanza03= getStanzaMessageSetTo("huawei@w3/index")
     var  stanza04= getStanzaMessageSetTo("huawei@w3")
     var  stanza05= getStanzaMessageSetTo("w3/index")
     var  stanza06= getStanzaMessageSetTo("huawei")
    @TestCase
    func test_ToTypeFilter_test_1(): Unit {
        var toTypeFilter=ToTypeFilter.ENTITY_FULL_JID
        @Assert(toTypeFilter.test(stanza01),false)
        @Assert(toTypeFilter.test(stanza02),false)
        @Assert(toTypeFilter.test(stanza03),true)
        @Assert(toTypeFilter.test(stanza04),false)
        @Assert(toTypeFilter.test(stanza05),false)
        @Assert(toTypeFilter.test(stanza06),false)


    }
    @TestCase
    func test_ToTypeFilter_test_2(): Unit {
        var toTypeFilter=ToTypeFilter.ENTITY_BARE_JID
        @Assert(toTypeFilter.test(stanza01),false)
        @Assert(toTypeFilter.test(stanza02),true)
        @Assert(toTypeFilter.test(stanza03),false)
        @Assert(toTypeFilter.test(stanza04),true)
        @Assert(toTypeFilter.test(stanza05),false)
        @Assert(toTypeFilter.test(stanza06),false)

    }
    @TestCase
    func test_ToTypeFilter_test_3(): Unit {
        var toTypeFilter=ToTypeFilter.DOMAIN_FULL_JID
        @Assert(toTypeFilter.test(stanza01),false)
        @Assert(toTypeFilter.test(stanza02),false)
        @Assert(toTypeFilter.test(stanza03),false)
        @Assert(toTypeFilter.test(stanza04),false)
        @Assert(toTypeFilter.test(stanza05),true)
        @Assert(toTypeFilter.test(stanza06),false)

    }
    @TestCase
    func test_ToTypeFilter_test_4(): Unit {
        var toTypeFilter=ToTypeFilter.DOMAIN_BARE_JID
        @Assert(toTypeFilter.test(stanza01),false)
        @Assert(toTypeFilter.test(stanza02),false)
        @Assert(toTypeFilter.test(stanza03),false)
        @Assert(toTypeFilter.test(stanza04),false)
        @Assert(toTypeFilter.test(stanza05),false)
        @Assert(toTypeFilter.test(stanza06),true)

    }
    @TestCase
    func test_ToTypeFilter_test_5(): Unit {
        var toTypeFilter=ToTypeFilter.TO_ANY_JID
        @Assert(toTypeFilter.test(stanza01),false)
        @Assert(toTypeFilter.test(stanza02),true)
        @Assert(toTypeFilter.test(stanza03),true)
        @Assert(toTypeFilter.test(stanza04),true)
        @Assert(toTypeFilter.test(stanza05),true)
        @Assert(toTypeFilter.test(stanza06),true)

    }
}
