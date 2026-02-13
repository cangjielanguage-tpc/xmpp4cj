// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityBareFromOrNull_01(): Unit {
        let jid=JidCreate.entityBareFromOrNull("local@domain/resource").getOrThrow()
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isEntityBareJid(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFromOrNull_02(): Unit {
        let jid=JidCreate.entityBareFromOrNull("localdomain/resource")
        @Assert(jid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFromOrNull_03(): Unit {
        let jid=JidCreate.entityBareFromOrNull("localdomain")
        @Assert(jid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFromOrNull_04(): Unit {
        @Assert(JidCreate.entityBareFromOrNull("").isNone(),true)
    }
}