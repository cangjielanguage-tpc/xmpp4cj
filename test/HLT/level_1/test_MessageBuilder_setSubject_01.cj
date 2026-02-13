// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_setSubject_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setSubject("MessageBuilder Subject")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getSubject(),"MessageBuilder Subject")
    }
    @TestCase
    func test_MessageBuilder_setSubject_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setSubject("")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getSubject(),"")
    }
    @TestCase
    func test_MessageBuilder_setSubject_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.setSubject("MessageBuilder Subject 01")
        try{
            msgBuilder.setSubject("MessageBuilder Subject 02")
            @Assert(false)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("Subject with the language None already exists")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}