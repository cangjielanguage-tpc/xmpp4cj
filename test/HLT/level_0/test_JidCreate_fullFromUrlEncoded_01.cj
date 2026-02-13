// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_fullFromUrlEncoded_01(): Unit {
        let fullId = JidCreate.fullFromUrlEncoded("xmpp://local@domain/res")
        let domainfullId  =fullId.asDomainFullJidOrThrow()
        @Assert(domainfullId.getLocalpartOrNull().isNone(),true)
        @Assert(domainfullId.getDomain().toString(),"xmpp:")
        @Assert(domainfullId.getResourceOrThrow().toString(),"/local@domain/res")
        let e:IllegalStateException=@AssertThrows[IllegalStateException](fullId.asEntityFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'xmpp://local@domain/res' can not be converted to EntityFullJid")
    }
    @TestCase
    func test_JidCreate_fullFromUrlEncoded_02(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFromUrlEncoded("local@domain"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@domain': XmppStringprepException: XmppStringprepException caused by 'local@domain/None': XmppStringprepException: resourcepart can't be None")
    }
    @TestCase
    func test_JidCreate_fullFromUrlEncoded_03(): Unit {
        let fullId = JidCreate.fullFromUrlEncoded("domain/res")

        let domainfullId = fullId.asDomainFullJidOrThrow()
        @Assert(domainfullId is DomainFullJid,true)
        @Assert(domainfullId.getDomain().toString(),"domain")
        @Assert(domainfullId.getResourceOrThrow().toString(),"res")
        let e:IllegalStateException=@AssertThrows[IllegalStateException](fullId.asEntityFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domain/res' can not be converted to EntityFullJid")
    }
}
