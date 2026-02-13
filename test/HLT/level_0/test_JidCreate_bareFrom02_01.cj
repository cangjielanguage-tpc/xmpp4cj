// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_bareFrom02_01(): Unit {
        let xmppcontext=XmppContext.getDefaultContext()
        let jid=JidCreate.bareFrom("local@domain/resource",xmppcontext)
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isEntityBareJid(),true)
        @Assert(jid is BareJid,true)

        @Assert(jid.getLocalpartOrThrow().toString(),"local")
        @Assert(jid.getDomain().toString(),"domain")

        let entryBareJid=jid.asEntityBareJidIfPossible().getOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryBareJid.getDomain().toString(),"domain")

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)

        let entryJid=jid.asEntityJidIfPossible().getOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        //@Assert(entryJid.getResourceOrThrow().toString(),"resource")

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
}