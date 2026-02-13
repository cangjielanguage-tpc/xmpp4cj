// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_domainBareFromUrlEncoded_01(): Unit {
        let jid=JidCreate.domainBareFromUrlEncoded("xmpp://local@domain/res")
        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"xmpp:")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"xmpp:")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_domainBareFromUrlEncoded_02(): Unit {
        let jid=JidCreate.domainBareFromUrlEncoded("local@domain/res")

        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

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
    func test_JidCreate_domainBareFromUrlEncoded_03(): Unit {
         let jid=JidCreate.domainBareFromUrlEncoded("domain/res")

        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrNull().isNone(),true)
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible()
        @Assert(entryBareJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible()
        @Assert(entryJid.isNone(),true)

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
}
