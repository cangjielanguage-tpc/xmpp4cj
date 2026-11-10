// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjIQTypeFilter {
    var stanza01 = Session()
    var stanza02 = Bind.newSet(Resourcepart.fromOrNull("resource"))
    var stanza03 = EmptyResultIQ()
    var stanzaErrorBuilder = StanzaError.froms(StanzaErrorCondition.forbidden, "StanzaErrorBuilder_me")
    var stanza04 = ErrorIQ.builder(stanzaErrorBuilder.build()).build()
    var stanza05 = UnparsedIQ("UnparsedIQelement", "UnparsedIQnamespace", "UnparsedIQcontent")

    @TestCase
    func test_IQTypeFilter_test_1(): Unit {
        var iqTypeFilter = IQTypeFilter.GET
        @Assert(iqTypeFilter.test(stanza01),false)
        @Assert(iqTypeFilter.test(stanza02),false)
        @Assert(iqTypeFilter.test(stanza03),false)
        @Assert(iqTypeFilter.test(stanza04),false)
        @Assert(iqTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_IQTypeFilter_test_2(): Unit {
        var iqTypeFilter = IQTypeFilter.SET
        @Assert(iqTypeFilter.test(stanza01),true)
        @Assert(iqTypeFilter.test(stanza02),true)
        @Assert(iqTypeFilter.test(stanza03),false)
        @Assert(iqTypeFilter.test(stanza04),false)
        @Assert(iqTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_IQTypeFilter_test_3(): Unit {
        var iqTypeFilter = IQTypeFilter.RESULT
        @Assert(iqTypeFilter.test(stanza01),false)
        @Assert(iqTypeFilter.test(stanza02),false)
        @Assert(iqTypeFilter.test(stanza03),true)
        @Assert(iqTypeFilter.test(stanza04),false)
        @Assert(iqTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_IQTypeFilter_test_4(): Unit {
        var iqTypeFilter = IQTypeFilter.ERROR
        @Assert(iqTypeFilter.test(stanza01),false)
        @Assert(iqTypeFilter.test(stanza02),false)
        @Assert(iqTypeFilter.test(stanza03),false)
        @Assert(iqTypeFilter.test(stanza04),true)
        @Assert(iqTypeFilter.test(stanza05),true)
    }
    @TestCase
    func test_IQTypeFilter_test_5(): Unit {
        var iqTypeFilter = IQTypeFilter.GET_OR_SET
        @Assert(iqTypeFilter.test(stanza01),true)
        @Assert(iqTypeFilter.test(stanza02),true)
        @Assert(iqTypeFilter.test(stanza03),false)
        @Assert(iqTypeFilter.test(stanza04),false)
        @Assert(iqTypeFilter.test(stanza05),false)
    }
}
