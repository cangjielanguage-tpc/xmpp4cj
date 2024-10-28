// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjThreadFilter{
    var threadFilter=ThreadFilter("meaasge_thread")

    @TestCase
    func test_ThreadFilter_test_1(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        @Assert(threadFilter.test(stanza01),false)
    }
    @TestCase
    func test_ThreadFilter_test_2(): Unit {
        var msgBuilder= StanzaBuilder.buildMessage("message01")
        msgBuilder.setThread("meaasge_thread")
        var stanza02= msgBuilder.build()
        @Assert(threadFilter.test(stanza02),true)

    }
    @TestCase
    func test_ThreadFilter_test_3(): Unit {
        var stanza01= StanzaBuilder.buildMessage().build()
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza01,"message02")
        msgBuilder.setThread("    ")
        var stanza03= msgBuilder.build()
        @Assert(threadFilter.test(stanza03),false)
    }
    @TestCase
    func test_ThreadFilter_test_4(): Unit {
        var msgBuilder_tmp= StanzaBuilder.buildMessage("message01")
        msgBuilder_tmp.setThread("msgthread")
        var stanza02= msgBuilder_tmp.build()
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT)
        var stanza04= msgBuilder.build()
        @Assert(threadFilter.test(stanza04),false)
    }
    @TestCase
    func test_ThreadFilter_test_5(): Unit {
        var stanza05= getStanzaUnparsedIQSetType(None<IQType>);
        @Assert(threadFilter.test(stanza05),false)
    }
}
