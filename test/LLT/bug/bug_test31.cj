// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_fromUrlEncoded_04(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.fromUrlEncoded("xmpp:local@domain/resource"))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'xmpp:local@domain/resource': XmppStringprepException: Localpart must not contain ':'")
    }
}
