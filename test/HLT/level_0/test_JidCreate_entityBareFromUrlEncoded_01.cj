// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_entityBareFromUrlEncoded_01(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityBareFromUrlEncoded("xmpp://local@domain/res"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'xmpp://local@domain/res': XmppStringprepException: localpart can't be None")

    }
    @TestCase
    func test_JidCreate_entityBareFromUrlEncoded_02(): Unit {
        let jid=JidCreate.entityBareFromUrlEncoded("local@domain/res")

        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryBareJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let entryJid=jid.asEntityJidOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryJid.getResourceOrNull().isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFromUrlEncoded_03(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityBareFromUrlEncoded("domain/res"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'domain/res': XmppStringprepException: localpart can't be None")

    }
}
