// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_StanzaBuilder_buildMessageFrom01_02(): Unit {
        //public static func buildMessageFrom (Message message, stanzaId:?String):MessageBuilder
        let oriMsg = StanzaBuilder.buildMessage().build()
        var stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildMessageFrom(oriMsg,stanzaId))
        println(e.toString())
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be the empty String")
    }
}
