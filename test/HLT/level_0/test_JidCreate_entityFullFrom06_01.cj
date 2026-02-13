// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityFullFrom06_01(): Unit {
        let localPart=Localpart.froms("abcs")
        let domainBareJid=JidCreate.froms("local","domain","res").asDomainBareJid()
        let res=Resourcepart.froms("res")
        let jid=JidCreate.entityFullFrom(localPart,domainBareJid,res)

        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"abcs")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"abcs")
        @Assert(entryBareJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let entryJid=jid.asEntityJidOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"abcs")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryJid.getResourceOrThrow().toString(),"res")

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidOrThrow ()
        @Assert(entryFullJid.getLocalpartOrThrow().toString(),"abcs")
        @Assert(entryFullJid.getDomain().toString(),"domain")
        @Assert(entryFullJid.getResourceOrThrow().toString(),"res")

        let fullJid=jid.asFullJidOrThrow()
        @Assert(fullJid.getLocalpartOrThrow().toString(),"abcs")
        @Assert(fullJid.getDomain().toString(),"domain")
        @Assert(fullJid.getResourceOrThrow().toString(),"res")

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)

        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asDomainFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'abcs@domain/res' can not be converted to DomainFullJid")
    }
}