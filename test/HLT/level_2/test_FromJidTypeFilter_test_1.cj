// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjFromJidTypeFilter{
    var stanza01= StanzaBuilder.buildMessage().build();
    var stanza02= StanzaBuilder.buildPresence("presence01").build();
    var stanza03= Session()
    var formjidString=["domain","local@domain","domain/res"]
    @TestCase
    func test_FromJidTypeFilter_test_1(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.DomainJid)
        stanza01.setFrom(JidCreate.froms(formjidString[0]))
        let e:IllegalStateException=@AssertThrows[IllegalStateException](fromJidTypeFilter.test(stanza01))
        @Assert(e.toString(),"IllegalStateException")
    }
    @TestCase
    func test_FromJidTypeFilter_test_2(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.DomainJid)
        stanza01.setFrom(JidCreate.froms(formjidString[1]))
        let e:IllegalStateException=@AssertThrows[IllegalStateException](fromJidTypeFilter.test(stanza01))
        @Assert(e.toString(),"IllegalStateException")
    }
    @TestCase
    func test_FromJidTypeFilter_test_3(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.DomainJid)
        stanza01.setFrom(JidCreate.froms(formjidString[2]))
        let e:IllegalStateException=@AssertThrows[IllegalStateException](fromJidTypeFilter.test(stanza01))
        @Assert(e.toString(),"IllegalStateException")
    }
}
