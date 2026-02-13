// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_domainFullFromUrlEncoded_01(): Unit {
        let jid=JidCreate.domainFullFromUrlEncoded("xmpp://local@domain/res")
        let bareJid=jid.asBareJid()

        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"xmpp:")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible().getOrThrow()
        @Assert(fullJid.getLocalpartOrNull().isNone(),true)
        @Assert(fullJid.getDomain().toString(),"xmpp:")
        @Assert(fullJid.getResourceOrThrow().toString(),"/local@domain/res")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"xmpp:")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible().getOrThrow()
        @Assert(domainfullJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainfullJid.getDomain().toString(),"xmpp:")
        @Assert(domainfullJid.getResourceOrThrow().toString(),"/local@domain/res")
    }
    @TestCase
    func test_JidCreate_domainFullFromUrlEncoded_02(): Unit {
        let jid=JidCreate.domainFullFromUrlEncoded("local@domain/res")

        let bareJid=jid.asBareJid()

        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible().getOrThrow()
        @Assert(fullJid.getLocalpartOrNull().isNone(),true)
        @Assert(fullJid.getDomain().toString(),"domain")
        @Assert(fullJid.getResourceOrThrow().toString(),"res")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible().getOrThrow()
        @Assert(domainfullJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainfullJid.getDomain().toString(),"domain")
        @Assert(domainfullJid.getResourceOrThrow().toString(),"res")
    }
    @TestCase
    func test_JidCreate_domainFullFromUrlEncoded_03(): Unit {
         let jid=JidCreate.domainFullFromUrlEncoded("domain/res")

        let bareJid=jid.asBareJid()

        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible().getOrThrow()
        @Assert(fullJid.getLocalpartOrNull().isNone(),true)
        @Assert(fullJid.getDomain().toString(),"domain")
        @Assert(fullJid.getResourceOrThrow().toString(),"res")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible().getOrThrow()
        @Assert(domainfullJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainfullJid.getDomain().toString(),"domain")
        @Assert(domainfullJid.getResourceOrThrow().toString(),"res")
    }
}
