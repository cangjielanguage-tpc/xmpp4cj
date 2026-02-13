// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_froms02_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let jid=JidCreate.froms("local","domain","resource")
        let actIqData=iqData.froms(jid)
        let actIqDataJID=actIqData.getFrom().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"domain")
        @Assert(actIqDataJID.getLocalpartOrThrow().toString(),"local")
        @Assert(actIqDataJID.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_IqData_froms02_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        var iqData=StanzaBuilder.buildIqData(stanzaId)
        iqData=iqData.froms(None<Jid>)
        @Assert(iqData.getTo().isNone(),true)
    }
}