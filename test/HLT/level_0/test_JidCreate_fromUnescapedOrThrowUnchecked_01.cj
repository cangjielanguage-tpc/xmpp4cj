// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fromUnescapedOrThrowUnchecked_01(): Unit {
        let jid=JidCreate.fromUnescapedOrThrowUnchecked("local@domain/resource")
        @Assert(jid.getDomain().toString(),"domain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
        @Assert(jid.getLocalpartOrThrow().toString(),"local")
    }
    @TestCase
    func test_JidCreate_fromUnescapedOrThrowUnchecked_02(): Unit {
        let jid=JidCreate.fromUnescapedOrThrowUnchecked("localdomain/resource")
        @Assert(jid.getDomain().toString(),"localdomain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_JidCreate_fromUnescapedOrThrowUnchecked_03(): Unit {
        let jid=JidCreate.fromUnescapedOrThrowUnchecked("localdomain")
        @Assert(jid.getDomain().toString(),"localdomain")
    }
    @TestCase
    func test_JidCreate_fromUnescapedOrThrowUnchecked_04(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.fromUnescapedOrThrowUnchecked(""))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart")

    }
}