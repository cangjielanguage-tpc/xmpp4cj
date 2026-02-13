// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_entityFromUrlEncoded_01(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityFromUrlEncoded("xmpp://local@domain/res"))
        @Assert(e.toString(),"XmppStringprepException: xmpp://local@domain/res")
    }
    @TestCase
    func test_JidCreate_entityFromUrlEncoded_02(): Unit {
        let jid=JidCreate.entityFromUrlEncoded("local@domain/res")

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
        @Assert(entryJid.getResourceOrThrow().toString(),"res")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible().getOrThrow()
        @Assert(entryFullJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryFullJid.getDomain().toString(),"domain")
        @Assert(entryFullJid.getResourceOrThrow().toString(),"res")

        let fullJid=jid.asFullJidIfPossible().getOrThrow()
        @Assert(fullJid.getLocalpartOrThrow().toString(),"local")
        @Assert(fullJid.getDomain().toString(),"domain")
        @Assert(fullJid.getResourceOrThrow().toString(),"res")

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityFromUrlEncoded_03(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityFromUrlEncoded("domain/res"))
        @Assert(e.toString(),"XmppStringprepException: domain/res")
    }
}
