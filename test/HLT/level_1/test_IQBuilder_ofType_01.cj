// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqBuilder{
    @TestCase
    func test_IqBuilder_ofType_01(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaError=StanzaError(StanzaErrorCondition.gone,"conditionTextString","errorGenerator",StanzaErrorType.MODIFY,HashMap<String,String>(),Array<ExtensionElement>())
        let errorIQBuilder=ErrorIQ.builder(stanzaError)
        @Assert(errorIQBuilder.getType(),IQType.error)
        let errorIQBuilderModify=errorIQBuilder.ofType(IQType.result)
        @Assert(errorIQBuilderModify.getType(),IQType.result)
    }
}