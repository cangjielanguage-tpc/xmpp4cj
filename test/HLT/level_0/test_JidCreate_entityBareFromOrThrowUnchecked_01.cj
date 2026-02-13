// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityBareFromOrThrowUnchecked_01(): Unit {
        let jid=JidCreate.entityBareFromOrThrowUnchecked("local@domain/resource")
        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryBareJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityFullJidOrThrow ())
        @Assert(e.toString(),"IllegalStateException: The JID 'local@domain' can not be converted to EntityFullJid")


        let entryJid=jid.asEntityJidOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryJid.getResourceOrNull().isNone(),true)

        let e1:IllegalStateException=@AssertThrows[IllegalStateException](jid.asFullJidOrThrow())
        @Assert(e1.toString(),"IllegalStateException: The JID 'local@domain' can not be converted to EntityBareJid")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFromOrThrowUnchecked_02(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.entityBareFromOrThrowUnchecked("localdomain/resource"))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by 'localdomain/resource': XmppStringprepException: localpart can't be None")

    }
    @TestCase
    func test_JidCreate_entityBareFromOrThrowUnchecked_03(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.entityBareFromOrThrowUnchecked("localdomain"))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by 'localdomain': XmppStringprepException: localpart can't be None")

    }
    @TestCase
    func test_JidCreate_entityBareFromOrThrowUnchecked_04(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.entityBareFromOrThrowUnchecked(""))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")

    }
}