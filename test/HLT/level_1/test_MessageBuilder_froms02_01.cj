// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_froms02_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let jid=JidCreate.froms("local","domain","resource")
        msgBuilder.froms(jid)
        let actMsgJID=msgBuilder.getFrom().getOrThrow()
        @Assert(actMsgJID.getDomain().toString(),"domain")
        @Assert(actMsgJID.getLocalpartOrThrow().toString(),"local")
        @Assert(actMsgJID.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_MessageBuilder_froms02_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.froms(None<Jid>)
        @Assert(msgBuilder.getFrom().isNone(),true)
    }
}