// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjPresenceTypeFilter {
    var stanza01 = StanzaBuilder.buildPresence().build();
    var stanza02 = StanzaBuilder.buildPresence("presence01").build();
    var stanza03 = StanzaBuilder.buildPresenceFrom(stanza01, "presence02").build();
    var stanza04 = StanzaBuilder.buildPresenceFrom(stanza02, StandardStanzaIdSource.DEFAULT).build();
    var stanza05 = getStanzaUnparsedIQSetType(None<IQType>);
    @TestCase
    func test_PresenceTypeFilter_test_1(): Unit {
        var pseTypeFilter = PresenceTypeFilter.ERROR
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_2(): Unit {
        var pseTypeFilter = PresenceTypeFilter.AVAILABLE
        @Assert(pseTypeFilter.test(stanza01),true)
        @Assert(pseTypeFilter.test(stanza02),true)
        @Assert(pseTypeFilter.test(stanza03),true)
        @Assert(pseTypeFilter.test(stanza04),true)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_3(): Unit {
        var pseTypeFilter = PresenceTypeFilter.OUTGOING_PRESENCE_BROADCAST
        @Assert(pseTypeFilter.test(stanza01),true)
        @Assert(pseTypeFilter.test(stanza02),true)
        @Assert(pseTypeFilter.test(stanza03),true)
        @Assert(pseTypeFilter.test(stanza04),true)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_4(): Unit {
        var pseTypeFilter = PresenceTypeFilter.PROBE
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_5(): Unit {
        var pseTypeFilter = PresenceTypeFilter.SUBSCRIBE
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_6(): Unit {
        var pseTypeFilter = PresenceTypeFilter.SUBSCRIBED
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_7(): Unit {
        var pseTypeFilter = PresenceTypeFilter.UNAVAILABLE
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_8(): Unit {
        var pseTypeFilter = PresenceTypeFilter.UNSUBSCRIBED
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_PresenceTypeFilter_test_9(): Unit {
        var pseTypeFilter = PresenceTypeFilter.UNSUBSCRIBE
        @Assert(pseTypeFilter.test(stanza01),false)
        @Assert(pseTypeFilter.test(stanza02),false)
        @Assert(pseTypeFilter.test(stanza03),false)
        @Assert(pseTypeFilter.test(stanza04),false)
        @Assert(pseTypeFilter.test(stanza05),false)
    }
}
