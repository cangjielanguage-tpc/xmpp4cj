// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_addBody_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        try{
            msgBuilder.addBody("","MessageBuilder Body 01")
            @Assert(false)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("language must be None or not empty")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_MessageBuilder_addBody_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.addBody("MessageBuilder languageStr","MessageBuilder Body 01")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getBody().isNone())
    }
    @TestCase
    func test_MessageBuilder_addBody_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.addBody(None<String>,"MessageBuilder Body 01")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getBody(),"MessageBuilder Body 01")
    }
}