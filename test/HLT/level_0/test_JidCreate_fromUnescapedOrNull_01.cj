// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fromUnescapedOrNull_01(): Unit {
        let jid=JidCreate.fromUnescapedOrNull("local@domain/resource").getOrThrow()
        @Assert(jid.getDomain().toString(),"domain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
        @Assert(jid.getLocalpartOrThrow().toString(),"local")
    }
    @TestCase
    func test_JidCreate_fromUnescapedOrNull_02(): Unit {
        let jid=JidCreate.fromUnescapedOrNull("localdomain/resource").getOrThrow()
        @Assert(jid.getDomain().toString(),"localdomain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_JidCreate_fromUnescapedOrNull_03(): Unit {
        let jid=JidCreate.fromUnescapedOrNull("localdomain").getOrThrow()
        @Assert(jid.getDomain().toString(),"localdomain")
    }
    @TestCase
    func test_JidCreate_fromUnescapedOrNull_04(): Unit {
        @Assert(JidCreate.fromUnescapedOrNull("").isNone(),true)
    }
}