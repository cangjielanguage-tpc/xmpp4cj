// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fromUrlEncoded_01(): Unit {
        let jid=JidCreate.fromUrlEncoded("http://www.baidu.com/index")
        @Assert(jid.getDomain().toString(),"http:")
        @Assert(jid.getResourceOrThrow().toString(),"/www.baidu.com/index")
        @Assert(jid.getLocalpartOrNull().isNone(),true)
    }
    @TestCase
    func test_JidCreate_fromUrlEncoded_02(): Unit {
        let jid=JidCreate.fromUrlEncoded("http://www.baidu.com/index?name=kitty&age=12")
        @Assert(jid.getDomain().toString(),"http:")
        @Assert(jid.getResourceOrThrow().toString(),"/www.baidu.com/index?name=kitty&age=12")
    }
    @TestCase
    func test_JidCreate_fromUrlEncoded_03(): Unit {
        let jid=JidCreate.fromUrlEncoded("xmpp://local@domain/resource")
        @Assert(jid.getDomain().toString(),"xmpp:")
        @Assert(jid.getResourceOrThrow().toString(),"/local@domain/resource")
    }
    @TestCase
    func test_JidCreate_fromUrlEncoded_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fromUrlEncoded("xmpp:local@domain/resource"))

        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'xmpp:local@domain/resource': XmppStringprepException: Localpart must not contain ':'")
    }
    @TestCase
    func test_JidCreate_fromUrlEncoded_05(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fromUrlEncoded(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart")
    }
}