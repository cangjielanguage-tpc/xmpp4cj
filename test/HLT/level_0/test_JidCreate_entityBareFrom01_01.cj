// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityBareFrom01_01(): Unit {
        let jid=JidCreate.entityBareFrom("local@domain/resource")
        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryBareJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFrom01_02(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityBareFrom("localdomain/resource"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'localdomain/resource': XmppStringprepException: localpart can't be None")
    }
    @TestCase
    func test_JidCreate_entityBareFrom01_03(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityBareFrom("localdomain"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'localdomain': XmppStringprepException: localpart can't be None")

    }
    @TestCase
    func test_JidCreate_entityBareFrom01_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityBareFrom(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")
    }
}