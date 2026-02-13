// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqBuilder{
    @TestCase
    func test_IqBuilder_build_01(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let extensionElement01=SessionFeature(true)
        let stanzaError=StanzaError(StanzaErrorCondition.gone,"conditionTextString","errorGenerator",StanzaErrorType.MODIFY,HashMap<String,String>([("ele01","name01")]),[extensionElement01])
        let errorIQBuilder=ErrorIQ.builder(stanzaError)
        let errorIQ=errorIQBuilder.build()
        @Assert(errorIQ.getType(),IQType.error)
    }
}