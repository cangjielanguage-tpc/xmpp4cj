// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_domainFullFromOrThrowUnchecked_01(): Unit {
        let jid=JidCreate.domainFullFromOrThrowUnchecked("local@domain/resource")
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

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_domainFullFromOrThrowUnchecked_02(): Unit {
        let jid=JidCreate.domainFullFromOrThrowUnchecked("localdomain/resource")
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
    func test_JidCreate_domainFullFromOrThrowUnchecked_03(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.domainFullFromOrThrowUnchecked("localdomain"))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by 'localdomain': XmppStringprepException: resourcepart can't be None")
    }
    @TestCase
    func test_JidCreate_domainFullFromOrThrowUnchecked_04(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.domainFullFromOrThrowUnchecked(""))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")
    }
}