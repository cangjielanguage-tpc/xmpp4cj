// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fromUnescaped_01(): Unit {
        let jid=JidCreate.fromUnescaped("local@domain/resource")
        @Assert(jid.getDomain().toString(),"domain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
        @Assert(jid.getLocalpartOrThrow().toString(),"local")
    }
    @TestCase
    func test_JidCreate_fromUnescaped_02(): Unit {
        let jid=JidCreate.fromUnescaped("localdomain/resource")
        @Assert(jid.getDomain().toString(),"localdomain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
    }
    @TestCase
    func test_JidCreate_fromUnescaped_03(): Unit {
        let jid=JidCreate.fromUnescaped("localdomain")
        @Assert(jid.getDomain().toString(),"localdomain")
    }
    @TestCase
    func test_JidCreate_fromUnescaped_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fromUnescaped(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart")
    }
}