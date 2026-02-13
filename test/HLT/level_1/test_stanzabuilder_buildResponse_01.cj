// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

var tmpString=None<String>
@Test
public class TestXmpp4cjStanzaBuilderBuildResponse{
    //public static func buildResponse<SB> (request:StanzaView, builderFromStanzaId:(?String) -> SB):SB where SB<:StanzaBuilder
    @TestCase
    func test_StanzaBuilder_buildResponse_01(): Unit {
        let oriMsg=StanzaBuilder.buildMessage(Some("Message stanzaId")).build()
        let actSB=StanzaBuilder.buildResponse<MessageBuilder>(oriMsg,getMsgBuilder)
        let actSbStanzaId=actSB.build().getStanzaId().getOrThrow()
        @Assert(actSbStanzaId,"Message stanzaId")
    }
    @TestCase
    func test_StanzaBuilder_buildResponse_02(): Unit {//报错同test_StanzaBuilder_buildIqData_02
        let oriIqData=StanzaBuilder.buildIqData(Some("IqData stanzaId"))
        let actSB=StanzaBuilder.buildResponse<IqData>(oriIqData,getIqData)
        let e:UnsupportedException=@AssertThrows[UnsupportedException](actSB.build())
        @Assert(e.toString(),"UnsupportedException")
    }
    @TestCase
    func test_StanzaBuilder_buildResponse_03(): Unit {
        let oriPs=StanzaBuilder.buildPresence(Some("Presence stanzaId"))
        let actSB=StanzaBuilder.buildResponse<PresenceBuilder>(oriPs,getPresenceBuilder)
        let actSbStanzaId=actSB.build().getStanzaId().getOrThrow()
        @Assert(actSbStanzaId,"Presence stanzaId")
    }
    @TestCase
    func test_StanzaBuilder_buildResponse_04(): Unit {
        let oriIqBuilder=StanzaBuilder.buildIqData(Some("IqData stanzaId"))
        let actSB=StanzaBuilder.buildResponse<IqBuilder>(oriIqBuilder,getIqBuilder)
        let actSbStanzaId=actSB.build().getStanzaId().getOrThrow()
        @Assert(actSbStanzaId.isEmpty(),false)
    }
}
public func getMsgBuilder(stanzaId:?String):MessageBuilder{
    return StanzaBuilder.buildMessage(stanzaId)
}
public func getIqData(stanzaId:?String):IqData{
    return StanzaBuilder.buildIqData(stanzaId)
}
public func getIqBuilder(stanzaId:?String):IqBuilder{
    let stanzaError=StanzaError(StanzaErrorCondition.gone,Some("conditionTextString :${stanzaId}"),Some("errorGenerator"),StanzaErrorType.WAIT,HashMap<String,String>(),Array<ExtensionElement>())
    return ErrorIQ.builder(stanzaError)
}
public func getPresenceBuilder(stanzaId:?String):PresenceBuilder{
    return StanzaBuilder.buildPresence(stanzaId)
}