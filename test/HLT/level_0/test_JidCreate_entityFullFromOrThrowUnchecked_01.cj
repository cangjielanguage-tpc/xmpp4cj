// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityFullFromOrThrowUnchecked_01(): Unit {
        let jid=JidCreate.entityFullFromOrThrowUnchecked("local@domain/resource")
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
        @Assert(entryJid.getResourceOrThrow().toString(),"resource")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidOrThrow ()
        @Assert(entryFullJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryFullJid.getDomain().toString(),"domain")
        @Assert(entryFullJid.getResourceOrThrow().toString(),"resource")

        let fullJid=jid.asFullJidOrThrow()
        @Assert(fullJid.getLocalpartOrThrow().toString(),"local")
        @Assert(fullJid.getDomain().toString(),"domain")
        @Assert(fullJid.getResourceOrThrow().toString(),"resource")

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityFullFromOrThrowUnchecked_02(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.entityFullFromOrThrowUnchecked("localdomain/resource"))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException: XmppStringprepException caused by 'localdomain/resource': XmppStringprepException: XmppStringprepException caused by 'None@localdomain/resource': XmppStringprepException: localpart can't be None")
    }
    @TestCase
    func test_JidCreate_entityFullFromOrThrowUnchecked_03(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.entityFullFromOrThrowUnchecked("localdomain"))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException: XmppStringprepException caused by 'localdomain': XmppStringprepException: XmppStringprepException caused by 'None@localdomain/None': XmppStringprepException: localpart can't be None")
    }
    @TestCase
    func test_JidCreate_entityFullFromOrThrowUnchecked_04(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.entityFullFromOrThrowUnchecked(""))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException: XmppStringprepException caused by '': XmppStringprepException: XmppStringprepException caused by 'None@/None': XmppStringprepException: domainpart can't be the empty string")
    }
}