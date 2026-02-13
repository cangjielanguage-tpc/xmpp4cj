// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityFrom01_01(): Unit {
        let jid=JidCreate.entityFrom("local@domain/resource")
        @Assert(jid is EntityJid,true)
        @Assert(jid.asFullJidOrThrow().toString(),"local@domain/resource")
        @Assert(jid.asEntityFullJidOrThrow().toString(),"local@domain/resource")
    }
    @TestCase
    func test_JidCreate_entityFrom01_02(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityFrom("domain/resource"))
        @Assert(e.toString(),"XmppStringprepException: domain/resource")
    }
    @TestCase
    func test_JidCreate_entityFrom01_03(): Unit {
        let jid=JidCreate.entityFrom("local@domain")
        @Assert(jid is EntityJid,true)

        let bareJid=jid.asBareJid()

        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidIfPossible().getOrThrow()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible().getOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryJid.getResourceOrNull().isNone(),true)


        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityFrom01_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.entityFrom(""))
        @Assert(e.toString(),"XmppStringprepException")
    }
}