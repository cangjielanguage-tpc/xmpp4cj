// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjMessageBuilder{
    @TestCase
    func test_MessageBuilder_setError_01(): Unit {
        let stanzaId=Some("MessageStanzaId")
        var msgBuilder=StanzaBuilder.buildMessage(stanzaId)
        let stanzaError=StanzaError(StanzaErrorCondition.gone,Some("conditionTextString :${stanzaId}"),Some("errorGenerator"),StanzaErrorType.WAIT,HashMap<String,String>(),Array<ExtensionElement>())
        msgBuilder.setError(stanzaError)
        let actMsgError=msgBuilder.getError().getOrThrow()
        @Assert(actMsgError.getCondition(),StanzaErrorCondition.gone)
        @Assert(actMsgError.getConditionText().getOrThrow(),"conditionTextString :${stanzaId}")
        @Assert(actMsgError.getErrorGenerator().getOrThrow(),"errorGenerator")
        @Assert(actMsgError.getType().toString(),StanzaErrorType.WAIT.toString())
    }
}