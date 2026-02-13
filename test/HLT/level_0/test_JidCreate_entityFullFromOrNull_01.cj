// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityFullFromOrNull_01(): Unit {
        let jid=JidCreate.entityFullFromOrNull("local@domain/resource").getOrThrow()
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_entityFullFromOrNull_02(): Unit {
        let jid=JidCreate.entityFullFromOrNull("localdomain/resource")
        @Assert(jid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityFullFromOrNull_03(): Unit {
        let jid=JidCreate.entityFullFromOrNull("localdomain")
        @Assert(jid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityFullFromOrNull_04(): Unit {
        @Assert(JidCreate.entityFullFromOrNull("").isNone(),true)
    }
}