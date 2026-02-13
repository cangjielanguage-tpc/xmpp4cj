// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_setThread01_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setThread("Message thread")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.toString(),"Message Stanza [id=MessageStanzaId,]")
    }
    @TestCase
    func test_MessageBuilder_setThread01_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        try{
            msgBuilder=msgBuilder.setThread("")
            @Assert(false)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("thread must not be None nor empty")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_MessageBuilder_setThread02_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setThread("Message thread",None<String>)
        let actMsg=msgBuilder.build()
        @Assert(actMsg.toString(),"Message Stanza [id=MessageStanzaId,]")
    }
    @TestCase
    func test_MessageBuilder_setThread02_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.setThread("Message thread","Message parent")
        let actMsg=msgBuilder.build()
        @Assert(actMsg.toString(),"Message Stanza [id=MessageStanzaId,]")
    }
    @TestCase
    func test_MessageBuilder_setThread02_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        try{
            msgBuilder=msgBuilder.setThread("Message thread","")
            @Assert(false)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("parent must be None or not empty")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}