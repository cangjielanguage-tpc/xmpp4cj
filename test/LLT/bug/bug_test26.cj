// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_domainFullFrom01_03(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.domainFullFrom("localdomain"))
        @Assert(e.toString(), "XmppStringprepException: XmppStringprepException caused by 'localdomain': XmppStringprepException: resourcepart can't be None")
    }
}
