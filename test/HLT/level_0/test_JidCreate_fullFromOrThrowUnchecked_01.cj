// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fullFromOrThrowUnchecked_01(): Unit {
        let jid=JidCreate.fullFromOrThrowUnchecked("local@domain/resource")
        @Assert(jid.asFullJidOrThrow().toString(),"local@domain/resource")
    }
    @TestCase
    func test_JidCreate_fullFromOrThrowUnchecked_02(): Unit {
        let jid=JidCreate.fullFromOrThrowUnchecked("localdomain/resource")
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'localdomain/resource' can not be converted to EntityBareJid")

    }
    @TestCase
    func test_JidCreate_fullFromOrThrowUnchecked_03(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.fullFromOrThrowUnchecked("localdomain"))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by 'localdomain': XmppStringprepException: XmppStringprepException caused by 'None@localdomain/None': XmppStringprepException: resourcepart can't be None")
    }
    @TestCase
    func test_JidCreate_fullFromOrThrowUnchecked_04(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](JidCreate.fullFromOrThrowUnchecked(""))
        @Assert(e.toString(),"IllegalArgumentException: XmppStringprepException caused by '': XmppStringprepException: XmppStringprepException caused by 'None@/None': XmppStringprepException: domainpart can't be the empty string")

    }
}