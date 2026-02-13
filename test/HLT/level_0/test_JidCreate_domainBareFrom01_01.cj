// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_domainBareFrom01_01(): Unit {
        let jid=JidCreate.domainBareFrom("local@domain/resource")
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

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_domainBareFrom01_02(): Unit {
        let jid=JidCreate.domainBareFrom("localdomain/resource")
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

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"localdomain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_domainBareFrom01_03(): Unit {
        let jid=JidCreate.domainBareFrom("localdomain")
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

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"localdomain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_domainBareFrom01_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.domainBareFrom(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")
    }
}