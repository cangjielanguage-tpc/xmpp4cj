// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_bareFromUrlEncoded_01(): Unit {
        let jid=JidCreate.bareFromUrlEncoded("xmpp://local@domain/resource")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
        @Assert(jid.getDomain().toString(),"xmpp:")
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.getLocalpartOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'xmpp:' has no localpart")
    }
    @TestCase
    func test_JidCreate_bareFromUrlEncoded_02(): Unit {
        let jid=JidCreate.bareFromUrlEncoded("xmpp:localdomain/resource")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_bareFromUrlEncoded_03(): Unit {
        let jid=JidCreate.bareFromUrlEncoded("xmpp:localdomain")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_bareFromUrlEncoded_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.bareFromUrlEncoded(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")

    }
}