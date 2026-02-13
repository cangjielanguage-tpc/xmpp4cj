// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_domainBareFromOrNull_01(): Unit {
        let jid=JidCreate.domainBareFromOrNull("local@domain/resource").getOrThrow()
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_domainBareFromOrNull_02(): Unit {
        let jid=JidCreate.domainBareFromOrNull("localdomain/resource").getOrThrow()
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_domainBareFromOrNull_03(): Unit {
        let jid=JidCreate.domainBareFromOrNull("localdomain").getOrThrow()
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_domainBareFromOrNull_04(): Unit {
        @Assert(JidCreate.domainBareFromOrNull("").isNone(),true)
    }
}