// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjIqData {
    @TestCase
    func test_IqData_to01_01(): Unit {
        let stanzaId = Some("IqDataStanzaId")
        let iqData = StanzaBuilder.buildIqData(stanzaId)
        let actIqData = iqData.to("blue@qq/entry")
        let actIqDataJID = actIqData.getTo().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"qq")
        @Assert(actIqDataJID.getLocalpartOrThrow().toString(),"blue")
        @Assert(actIqDataJID.getResourceOrThrow().toString(),"entry")
    }

    @TestCase
    func test_IqData_to01_02(): Unit {
        let stanzaId = Some("IqDataStanzaId")
        let iqData = StanzaBuilder.buildIqData(stanzaId)
        let actIqData = iqData.to("blue@qq")
        let actIqDataJID = actIqData.getTo().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"qq")
    }

    @TestCase
    func test_IqData_to01_03(): Unit {
        let stanzaId = Some("IqDataStanzaId")
        let iqData = StanzaBuilder.buildIqData(stanzaId)
        let actIqData = iqData.to("qq/entry")
        let actIqDataJID = actIqData.getTo().getOrThrow()
        @Assert(actIqDataJID.getDomain().toString(),"qq")
    }

    @TestCase
    func test_IqData_to01_04(): Unit {
        let stanzaId = Some("IqDataStanzaId")
        let iqData = StanzaBuilder.buildIqData(stanzaId)
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](iqData.to(""))
        @Assert("XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart", e.toString())
    }
}
