// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_froms04_01(): Unit {
        let xmppcontext=XmppContext.getDefaultContext()
        let jid=JidCreate.froms("local@domain/resource",xmppcontext)
        @Assert(jid.getDomain().toString(),"domain")
        @Assert(jid.getResourceOrThrow().toString(),"resource")
        @Assert(jid.getLocalpartOrThrow().toString(),"local")
    }
}