// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fullFrom03_01(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFrom(None<String>,"","res"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'None@/res': XmppStringprepException: domainpart can't be the empty string")
    }
    @TestCase
    func test_JidCreate_fullFrom03_02(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFrom("","domain",""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '@domain/': XmppStringprepException: resourcepart can't be the empty string")
    }
    @TestCase
    func test_JidCreate_fullFrom03_03(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFrom("local","domain",""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@domain/': XmppStringprepException: resourcepart can't be the empty string")

    }
    @TestCase
    func test_JidCreate_fullFrom03_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFrom("local","","res"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@/res': XmppStringprepException: domainpart can't be the empty string")

    }
    @TestCase
    func test_JidCreate_fullFrom03_05(): Unit {
        var locals=[":","&","@"," "]
        for (local in locals){
            let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFrom(local, "dom.example", "res"))
            @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '${local}@dom.example/res': XmppStringprepException: Localpart must not contain '${local}'")
        }
    }
    @TestCase
    func test_JidCreate_fullFrom03_06(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.fullFrom(None<String>,"domainJid",None<String>))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'None@domainJid/None': XmppStringprepException: resourcepart can't be None")
    }
    @TestCase
    func test_JidCreate_fullFrom03_07(): Unit {
        let jid02=JidCreate.fullFrom("local","domain","resource")
        @Assert(jid02.asFullJidOrThrow().toString(),"local@domain/resource")
        @Assert(jid02.asEntityFullJidOrThrow().toString(),"local@domain/resource")
    }
    @TestCase
    func test_JidCreate_fullFrom03_08(): Unit {
        let jid04=JidCreate.fullFrom(None<String>, "domain","resource")
        let e1:IllegalStateException=@AssertThrows[IllegalStateException](jid04.asFullJidOrThrow())
        @Assert(e1.toString(),"IllegalStateException: The JID 'domain/resource' can not be converted to EntityBareJid")
        let e2:IllegalStateException=@AssertThrows[IllegalStateException](jid04.asEntityFullJidOrThrow())
        @Assert(e2.toString(),"IllegalStateException: The JID 'domain/resource' can not be converted to EntityFullJid")
    }
}