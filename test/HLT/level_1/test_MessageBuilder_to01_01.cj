// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_to01_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.to("blue@qq/entry")
        let actMsgJID=msgBuilder.getTo().getOrThrow()
        @Assert(actMsgJID.getDomain().toString(),"qq")
        @Assert(actMsgJID.getLocalpartOrThrow().toString(),"blue")
        @Assert(actMsgJID.getResourceOrThrow().toString(),"entry")
    }
    @TestCase
    func test_MessageBuilder_to01_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.to("blue@qq")
        let actMsgJID=msgBuilder.getTo().getOrThrow()
        @Assert(actMsgJID.getDomain().toString(),"qq")
        @Assert(actMsgJID.getLocalpartOrThrow().toString(),"blue")
        try{
            actMsgJID.getResourceOrThrow()
        }catch(e:IllegalStateException){
            if(e.toString().contains("The JID 'blue@qq' has no resourcepart")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_MessageBuilder_to01_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder=msgBuilder.to("qq/entry")
        var actMsgJID=msgBuilder.getTo().getOrThrow()
        @Assert(actMsgJID.getDomain().toString(),"qq")
        @Assert(actMsgJID.getResourceOrThrow().toString(),"entry")
        try{
            actMsgJID.getLocalpartOrThrow()
            @Assert(false)
        }catch(e:IllegalStateException){
            if(e.toString().contains("The JID 'qq/entry' has no localpart")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_MessageBuilder_to01_04(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](msgBuilder.to(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart")
    }
}