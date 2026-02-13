// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjMessageTypeFilter{
    var stanza01= StanzaBuilder.buildMessage().build();
    var stanza02= StanzaBuilder.buildMessage("message01").build();
    var stanza03= StanzaBuilder.buildMessageFrom(stanza01,"message02").build();
    var stanza04= StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT).build();
    var stanza05= getStanzaUnparsedIQSetType(None<IQType>);
    @TestCase
    func test_MessageTypeFilter_test_1(): Unit {
        var msgTypeFilter=MessageTypeFilter.ERROR
        @Assert(msgTypeFilter.test(stanza01),false)
        @Assert(msgTypeFilter.test(stanza02),false)
        @Assert(msgTypeFilter.test(stanza03),false)
        @Assert(msgTypeFilter.test(stanza04),false)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_2(): Unit {
        var  msgTypeFilter=MessageTypeFilter.CHAT
        @Assert(msgTypeFilter.test(stanza01),false)
        @Assert(msgTypeFilter.test(stanza02),false)
        @Assert(msgTypeFilter.test(stanza03),false)
        @Assert(msgTypeFilter.test(stanza04),false)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_3(): Unit {
        var  msgTypeFilter=MessageTypeFilter.GROUPCHAT
        @Assert(msgTypeFilter.test(stanza01),false)
        @Assert(msgTypeFilter.test(stanza02),false)
        @Assert(msgTypeFilter.test(stanza03),false)
        @Assert(msgTypeFilter.test(stanza04),false)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_4(): Unit {
        var  msgTypeFilter=MessageTypeFilter.HEADLINE
        @Assert(msgTypeFilter.test(stanza01),false)
        @Assert(msgTypeFilter.test(stanza02),false)
        @Assert(msgTypeFilter.test(stanza03),false)
        @Assert(msgTypeFilter.test(stanza04),false)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_5(): Unit {
        var  msgTypeFilter=MessageTypeFilter.NORMAL
        @Assert(msgTypeFilter.test(stanza01),true)
        @Assert(msgTypeFilter.test(stanza02),true)
        @Assert(msgTypeFilter.test(stanza03),true)
        @Assert(msgTypeFilter.test(stanza04),true)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_6(): Unit {
        var  msgTypeFilter=MessageTypeFilter.NORMAL_OR_CHAT
        @Assert(msgTypeFilter.test(stanza01),true)
        @Assert(msgTypeFilter.test(stanza02),true)
        @Assert(msgTypeFilter.test(stanza03),true)
        @Assert(msgTypeFilter.test(stanza04),true)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_7(): Unit {
        var  msgTypeFilter=MessageTypeFilter.NORMAL_OR_CHAT_OR_HEADLINE
        @Assert(msgTypeFilter.test(stanza01),true)
        @Assert(msgTypeFilter.test(stanza02),true)
        @Assert(msgTypeFilter.test(stanza03),true)
        @Assert(msgTypeFilter.test(stanza04),true)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
    @TestCase
    func test_MessageTypeFilter_test_8(): Unit {
        var  msgTypeFilter=MessageTypeFilter.NORMAL_OR_HEADLINE
        @Assert(msgTypeFilter.test(stanza01),true)
        @Assert(msgTypeFilter.test(stanza02),true)
        @Assert(msgTypeFilter.test(stanza03),true)
        @Assert(msgTypeFilter.test(stanza04),true)
        @Assert(msgTypeFilter.test(stanza05),false)
    }
}
