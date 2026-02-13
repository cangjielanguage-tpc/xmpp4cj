// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_getThis_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder
        @Assert(msgBuilder.getType().isNone(),true)
    }
}