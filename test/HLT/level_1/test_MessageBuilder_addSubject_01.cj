// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_addSubject_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        try{
            msgBuilder.addSubject("","MessageBuilder Subject 01")
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
    func test_MessageBuilder_addSubject_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.addSubject("MessageBuilder languageStr","MessageBuilder Subject 01")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getSubject().isNone())
    }
    @TestCase
    func test_MessageBuilder_addSubject_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.addSubject(None<String>,"MessageBuilder Subject 01")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.getSubject(),"MessageBuilder Subject 01")
    }
}