// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_setLanguage_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        iqData.setLanguage("zh-cn")
        @Assert(iqData.getLanguage(),"zh-cn")
    }
}