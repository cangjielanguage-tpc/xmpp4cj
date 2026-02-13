// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_bareFromOrNull_01(): Unit {
        let jid=JidCreate.bareFromOrNull("local@domain/resource").getOrThrow()
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isEntityBareJid(),true)
    }
    @TestCase
    func test_JidCreate_bareFromOrNull_02(): Unit {
        let jid=JidCreate.bareFromOrNull("localdomain/resource").getOrThrow()
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_bareFromOrNull_03(): Unit {
        let jid=JidCreate.bareFromOrNull("localdomain").getOrThrow()
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_bareFromOrNull_04(): Unit {
        @Assert(JidCreate.bareFromOrNull("").isNone(),true)
    }
}