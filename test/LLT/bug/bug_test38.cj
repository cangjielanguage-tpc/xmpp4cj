// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_entityFullFromUrlEncoded_01(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFromUrlEncoded("xmpp://local@domain/res"))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'xmpp://local@domain/res': XmppStringprepException: XmppStringprepException caused by 'None@xmpp://local@domain/res': XmppStringprepException: localpart can't be None")
    }
}
