// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_entityFullFrom03_01(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom(None<String>,"","res"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'None@/res': XmppStringprepException: domainpart can't be the empty string")
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_02(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("","domain",""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '@domain/': XmppStringprepException: localpart can't be the empty string")
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_03(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("local","domain",""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@domain/': XmppStringprepException: resourcepart can't be the empty string")
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_04(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("local","","res"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@/res': XmppStringprepException: domainpart can't be the empty string")
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_05(): Unit {
        var locals = [":", "&", "@", " "]
        for (local in locals) {
            let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom(local, "dom.example", "res"))
            @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '${local}@dom.example/res': XmppStringprepException: Localpart must not contain '${local}'")
        }
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_06(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom(None<String>,"domainJid",None<String>))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'None@domainJid/None': XmppStringprepException: localpart can't be None")
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_07(): Unit {
        let jid = JidCreate.entityFullFrom("local", "domain", "resource")
        let bareJid = jid.asBareJid()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid = jid.asEntityBareJidOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryBareJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let entryJid = jid.asEntityJidOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryJid.getResourceOrThrow().toString(),"resource")

        let domainbareJid = jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let entryFullJid = jid.asEntityFullJidOrThrow()
        @Assert(entryFullJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryFullJid.getDomain().toString(),"domain")
        @Assert(entryFullJid.getResourceOrThrow().toString(),"resource")

        let fullJid = jid.asFullJidOrThrow()
        @Assert(fullJid.getLocalpartOrThrow().toString(),"local")
        @Assert(fullJid.getDomain().toString(),"domain")
        @Assert(fullJid.getResourceOrThrow().toString(),"resource")

        let domainfullJid = jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityFullFrom03_08(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom(None<String>, "domain","resource"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'None@domain/resource': XmppStringprepException: localpart can't be None")
    }
}
