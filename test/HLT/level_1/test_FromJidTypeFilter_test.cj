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
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.BareJid)
        stanza01.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza01),true)

        stanza01.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza01),true)

        stanza01.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza01),false)
    }
    @TestCase
    func test_FromJidTypeFilter_test_2(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.DomainBareJid)
        stanza02.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza02),true)

        stanza02.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza02),false)

        stanza02.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza02),false)
    }
    @TestCase
    func test_FromJidTypeFilter_test_3(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.DomainFullJid)
        stanza03.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza03),false)

        stanza03.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza03),false)

        stanza03.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza03),true)
    }
    @TestCase
    func test_FromJidTypeFilter_test_5(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.EntityBareJid)
        stanza02.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza02),false)

        stanza02.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza02),true)

        stanza02.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza02),false)
    }
    @TestCase
    func test_FromJidTypeFilter_test_6(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.EntityFullJid)
        stanza03.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza03),false)

        stanza03.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza03),false)

        stanza03.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza03),false)
    }
    @TestCase
    func test_FromJidTypeFilter_test_7(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.EntityJid)
        stanza03.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza03),false)

        stanza03.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza03),true)

        stanza03.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza03),false)
    }
    @TestCase
    func test_FromJidTypeFilter_test_8(): Unit {
        var fromJidTypeFilter=FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.FullJid)
        stanza02.setFrom(JidCreate.froms(formjidString[0]))
        @Assert(fromJidTypeFilter.test(stanza02),false)

        stanza02.setFrom(JidCreate.froms(formjidString[1]))
        @Assert(fromJidTypeFilter.test(stanza02),false)

        stanza02.setFrom(JidCreate.froms(formjidString[2]))
        @Assert(fromJidTypeFilter.test(stanza02),true)
    }
}
