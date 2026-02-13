// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fullFrom02_01(): Unit {
        let xmppcontext=XmppContext.getDefaultContext()
        let jid=JidCreate.fullFrom("local@domain/resource",xmppcontext)
        @Assert(jid is FullJid,true)
        @Assert(jid.asFullJidOrThrow().toString(),"local@domain/resource")
        @Assert(jid.asEntityFullJidOrThrow().toString(),"local@domain/resource")
    }

}