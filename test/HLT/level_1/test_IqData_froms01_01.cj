// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjIqData{
    @TestCase
    func test_IqData_froms01_01(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let actIqData=iqData.froms("blue@qq/entry")
        let actIqDataJID=actIqData.getFrom().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"qq")
        @Assert(actIqDataJID.getLocalpartOrThrow().toString(),"blue")
        @Assert(actIqDataJID.getResourceOrThrow().toString(),"entry")
    }
    @TestCase
    func test_IqData_froms01_02(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let actIqData=iqData.froms("blue@qq")
        let actIqDataJID=actIqData.getFrom().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"qq")
    }
    @TestCase
    func test_IqData_froms01_03(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let actIqData=iqData.froms("qq/entry")
        let actIqDataJID=actIqData.getFrom().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"qq")
    }
    @TestCase
    func test_IqData_froms01_04(): Unit {
        let stanzaId=Some("IqDataStanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](iqData.froms(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart")

    }
}