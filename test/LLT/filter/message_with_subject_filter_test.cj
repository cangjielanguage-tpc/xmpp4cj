// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjMessageWithSubjectFilter {
    var msgWithSubjectFilter = MessageWithSubjectFilter.INSTANCE

    @TestCase
    func test_MessageWithSubjectFilter_test_1(): Unit {
        var stanza01 = StanzaBuilder.buildMessage().build()
        @Assert(msgWithSubjectFilter.test(stanza01),false)
    }
    @TestCase
    func test_MessageWithSubjectFilter_test_2(): Unit {
        var msgBuilder = StanzaBuilder.buildMessage("message01")
        msgBuilder.setSubject("")
        var stanza02 = msgBuilder.build()
        @Assert(msgWithSubjectFilter.test(stanza02),true)
    }
    @TestCase
    func test_MessageWithSubjectFilter_test_3(): Unit {
        var stanza01 = StanzaBuilder.buildMessage().build()
        var msgBuilder = StanzaBuilder.buildMessageFrom(stanza01, "message02")
        msgBuilder.setSubject("    ")
        var stanza03 = msgBuilder.build()
        @Assert(msgWithSubjectFilter.test(stanza03),true)
    }
    @TestCase
    func test_MessageWithSubjectFilter_test_4(): Unit {
        var msgBuilder_tmp = StanzaBuilder.buildMessage("message01");
        msgBuilder_tmp.setSubject("");
        var stanza02 = msgBuilder_tmp.build();

        var msgBuilder = StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT);
        // msgBuilder.setSubject("msg body")
        var stanza04 = msgBuilder.build()
        @Assert(msgWithSubjectFilter.test(stanza04),true)
    }
    @TestCase
    func test_MessageWithSubjectFilter_test_5(): Unit {
        var stanza05 = getStanzaUnparsedIQSetType(None<IQType>);
        @Assert(msgWithSubjectFilter.test(stanza05),false)
    }
}
