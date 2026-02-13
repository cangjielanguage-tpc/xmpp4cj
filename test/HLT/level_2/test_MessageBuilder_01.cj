// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_setThread_1(): Unit {
        var msgBuilder= StanzaBuilder.buildMessage("message01")
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](msgBuilder.setThread(""))
        @Assert(e.toString(),"IllegalArgumentException: thread must not be None nor empty")
    }
    @TestCase
    func test_MessageBuilder_setSubject_1(): Unit {
        var msgBuilder_tmp= StanzaBuilder.buildMessage("message01")
        msgBuilder_tmp.setSubject("")
        var stanza02= msgBuilder_tmp.build()
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](msgBuilder.setSubject("my_subject"))
        @Assert(e.toString(),"IllegalArgumentException: Subject with the language None already exists")
    }
    @TestCase
    func test_MessageBuilder_setBody_1(): Unit {
        var msgBuilder_tmp= StanzaBuilder.buildMessage("message01")
        msgBuilder_tmp.setBody("")
        var stanza02= msgBuilder_tmp.build()
        var msgBuilder= StanzaBuilder.buildMessageFrom(stanza02, StandardStanzaIdSource.DEFAULT)
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](msgBuilder.setBody("my_body"))
        @Assert(e.toString(),"IllegalArgumentException: Body with the language None already exists")
    }
    @TestCase
    func test_MessageBuilder_setthread_1(): Unit {
        var msgBuilder_tmp= StanzaBuilder.buildMessage("message01")
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](msgBuilder_tmp.setThread(""))
        @Assert(e.toString(),"IllegalArgumentException: thread must not be None nor empty")
    }
}
