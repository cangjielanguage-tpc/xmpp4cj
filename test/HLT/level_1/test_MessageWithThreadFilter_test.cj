// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjMessageWithThreadFilter{
    var msgWithThreadFilter=MessageWithThreadFilter.INSTANCE

    @TestCase
    func test_MessageWithThreadFilter_test_1(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        @Assert(msgWithThreadFilter.test(stanza01),false)
    }
    @TestCase
    func test_MessageWithThreadFilter_test_3(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza01,"message02")
        msgBuilder.setThread("    ")
        var stanza03= msgBuilder.build()
        @Assert(msgWithThreadFilter.test(stanza03),true)
    }
    @TestCase
    func test_MessageWithThreadFilter_test_4(): Unit {
        var msgBuilder_tmp= StanzaBuilder.buildMessage("message01");
        msgBuilder_tmp.setThread("my_thread01");
        var stanza02= msgBuilder_tmp.build();
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT);
        msgBuilder.setThread("my_thread02");
        var stanza04= msgBuilder.build()
        @Assert(msgWithThreadFilter.test(stanza04),true)
    }
    @TestCase
    func test_MessageWithThreadFilter_test_5(): Unit {
        var msgBuilder= StanzaBuilder.buildMessage("message01")
        msgBuilder.setThread("my_thread",None<String>)
        var stanza03= msgBuilder.build()
        @Assert(msgWithThreadFilter.test(stanza03),true)
    }
    @TestCase
    func test_MessageWithThreadFilter_test_6(): Unit {
        var msgBuilder= StanzaBuilder.buildMessage("message01")
        msgBuilder.setThread("my_thread","my_parent")
        var stanza03= msgBuilder.build()
        @Assert(msgWithThreadFilter.test(stanza03),true)
    }
    @TestCase
    func test_MessageWithThreadFilter_test_7(): Unit {
        var stanza05= getStanzaUnparsedIQSetType(None<IQType>);
        @Assert(msgWithThreadFilter.test(stanza05),false)
    }
}
