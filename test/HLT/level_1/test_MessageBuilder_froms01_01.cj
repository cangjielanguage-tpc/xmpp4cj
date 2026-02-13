// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_froms01_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.froms("blue@qq/entry")
        let actMsgJID=msgBuilder.getFrom().getOrThrow()
        @Assert(actMsgJID.getDomain().toString(),"qq")
        @Assert(actMsgJID.getLocalpartOrThrow().toString(),"blue")
        @Assert(actMsgJID.getResourceOrThrow().toString(),"entry")
    }
    @TestCase
    func test_MessageBuilder_froms01_02(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.froms("blue@qq")
        let actMsgJID=msgBuilder.getFrom().getOrThrow()
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
    func test_MessageBuilder_froms01_03(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        msgBuilder.froms("qq/entry")
        let actMsgJID=msgBuilder.getFrom().getOrThrow()
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
    func test_MessageBuilder_froms01_04(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](msgBuilder.froms(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart")

    }
}