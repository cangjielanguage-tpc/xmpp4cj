// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_bareFromUrlEncoded_04(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.bareFromUrlEncoded(""))
        @Assert("XmppStringprepException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string", e.toString())
    }
}
