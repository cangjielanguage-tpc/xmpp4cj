// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_getThis_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let actIqDataModify=iqData
        let actIqDataModifyType=actIqDataModify.getType()
        @Assert(actIqDataModifyType,IQType.get)
    }
}