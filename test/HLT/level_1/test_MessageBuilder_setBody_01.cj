// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_setBody_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setBody("MessageBuilder Body")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getBody(),"MessageBuilder Body")
    }
    @TestCase
    func test_MessageBuilder_setBody_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setBody("")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getBody(),"")
    }
    @TestCase
    func test_MessageBuilder_setBody_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.setBody("MessageBuilder Body 01")
        try{
            msgBuilder.setBody("MessageBuilder Body 02")
            @Assert(false)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("Body with the language None already exists")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}