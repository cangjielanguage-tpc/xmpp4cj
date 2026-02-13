// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_domainFullFromOrNull_01(): Unit {
        let jid=JidCreate.domainFullFromOrNull("local@domain/resource").getOrThrow()
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
        @Assert(fullJid.getResourceOrThrow().toString(),"resource")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible().getOrThrow()
        @Assert(domainfullJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainfullJid.getDomain().toString(),"domain")
        @Assert(domainfullJid.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_JidCreate_domainFullFromOrNull_02(): Unit {
        let jid=JidCreate.domainFullFromOrNull("localdomain/resource").getOrThrow()
        let bareJid=jid.asBareJid()

        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"localdomain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible().getOrThrow()
        @Assert(fullJid.getLocalpartOrNull().isNone(),true)
        @Assert(fullJid.getDomain().toString(),"localdomain")
        @Assert(fullJid.getResourceOrThrow().toString(),"resource")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"localdomain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible().getOrThrow()
        @Assert(domainfullJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainfullJid.getDomain().toString(),"localdomain")
        @Assert(domainfullJid.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_JidCreate_domainFullFromOrNull_03(): Unit {
        @Assert(JidCreate.domainFullFromOrNull("localdomain").isNone(),true)
    }
    @TestCase
    func test_JidCreate_domainFullFromOrNull_04(): Unit {
        @Assert(JidCreate.domainFullFromOrNull("").isNone(),true)
    }
}