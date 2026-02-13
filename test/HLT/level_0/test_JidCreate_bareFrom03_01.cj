// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_bareFrom03_01(): Unit {
        let localPart=Localpart.froms("abcs")
        let domainBareJid=JidCreate.froms("local","domain","res").asDomainBareJid()
        let jid=JidCreate.bareFrom(localPart,domainBareJid)
        @Assert(jid is BareJid,true)
        @Assert(jid.getDomain(),domainBareJid.getDomain())
        @Assert(jid.getLocalpartOrThrow (),localPart)
    }
    @TestCase
    func test_JidCreate_bareFrom04_01(): Unit {
        let localPart=None<Localpart>
        let domainpart=Domainpart.froms("domain.abd//")
        let jid=JidCreate.bareFrom(localPart,domainpart)
        @Assert(jid is BareJid,true)
        @Assert(jid.getDomain().toString(),domainpart.toString())
        @Assert(jid.getLocalpartOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_bareFrom04_02(): Unit {
        let localPart=Localpart.froms("local")
        let domainpart=Domainpart.froms("domain.abd//")
        let jid=JidCreate.bareFrom(localPart,domainpart)
        @Assert(jid is BareJid,true)
        @Assert(jid.getDomain(),domainpart)
        @Assert(jid.getLocalpartOrNull().getOrThrow(),localPart)
    }
}