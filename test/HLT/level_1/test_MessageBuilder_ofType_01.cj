// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_ofType_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.ofType(MessageType.headline)
        let actMsg=msgBuilder.build()
        @Assert(actMsg.toString(),"Message Stanza [id=MessageStanzaId,type=headline,]")
    }
}