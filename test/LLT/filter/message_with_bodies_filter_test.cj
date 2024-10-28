// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjMessageWithBodiesFilter{
    var msgWithBodiesFilter=MessageWithBodiesFilter.INSTANCE

    @TestCase
    func test_MessageWithBodiesFilter_test_1(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        @Assert(msgWithBodiesFilter.test(stanza01),false)
    }
    @TestCase
    func test_MessageWithBodiesFilter_test_2(): Unit {
        var msgBuilder= StanzaBuilder.buildMessage("message01")
        msgBuilder.setBody("")
        var stanza02= msgBuilder.build()
        @Assert(msgWithBodiesFilter.test(stanza02),true)

    }
    @TestCase
    func test_MessageWithBodiesFilter_test_3(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza01,"message02")
        msgBuilder.setBody("    ")
        var stanza03= msgBuilder.build()
        @Assert(msgWithBodiesFilter.test(stanza03),true)
    }
    @TestCase
    func test_MessageWithBodiesFilter_test_4(): Unit {
        var msgBuilder_tmp= StanzaBuilder.buildMessage("message01");
        msgBuilder_tmp.setBody("");
        var stanza02= msgBuilder_tmp.build();

        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT);
       // msgBuilder.setBody("msg body")
        var stanza04= msgBuilder.build()
        @Assert(msgWithBodiesFilter.test(stanza04),true)
    }
    @TestCase
    func test_MessageWithBodiesFilter_test_5(): Unit {
        var stanza05= getStanzaUnparsedIQSetType(None<IQType>);
        @Assert(msgWithBodiesFilter.test(stanza05),false)
    }
}
