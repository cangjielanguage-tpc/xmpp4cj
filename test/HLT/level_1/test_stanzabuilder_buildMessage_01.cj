// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjStanzaBuilderBuildMessage {
    @TestCase
    func test_StanzaBuilder_buildMessage01_01(): Unit {
        //public static func buildMessage ():MessageBuilder
        let msgBuilder=StanzaBuilder.buildMessage()
        let actMsg=msgBuilder.build()
        let actMsgtoString=actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza []")
    }
    @TestCase
    func test_StanzaBuilder_buildMessage02_01(): Unit {
        //buildMessage (stanzaId:?String):MessageBuilder
        let stanzaId=None<String>
        let msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let actMsg=msgBuilder.build()
        let actMsgtoString=actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza []")
    }
    @TestCase
    func test_StanzaBuilder_buildMessage02_02(): Unit {
        //buildMessage (stanzaId:?String):MessageBuilder
        let stanzaId=Some("")
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](StanzaBuilder.buildMessage(stanzaId))
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be the empty String")
    }
    @TestCase
    func test_StanzaBuilder_buildMessage02_03(): Unit {
        //buildMessage (stanzaId:?String):MessageBuilder
        let stanzaId=Some("jabber:iq:roster")
        let msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let actMsg=msgBuilder.build()
        let actMsgtoString=actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza [id=jabber:iq:roster,]")
    }
}