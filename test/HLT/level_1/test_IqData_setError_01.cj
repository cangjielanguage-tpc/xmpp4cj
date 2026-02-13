// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_setError_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let stanzaError=StanzaError(StanzaErrorCondition.gone,Some("conditionTextString :${stanzaId}"),Some("errorGenerator"),StanzaErrorType.WAIT,HashMap<String,String>(),Array<ExtensionElement>())
        iqData.setError(stanzaError)
        let actIqDataError=iqData.getError().getOrThrow()
        @Assert(actIqDataError.getCondition(),StanzaErrorCondition.gone)
        @Assert(actIqDataError.getConditionText().getOrThrow(),"conditionTextString :${stanzaId}")
        @Assert(actIqDataError.getErrorGenerator().getOrThrow(),"errorGenerator")
        @Assert(actIqDataError.getType().toString(),StanzaErrorType.WAIT.toString())
    }
}