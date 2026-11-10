// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_entityFullFrom03_04(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("local","","res"))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@/res': XmppStringprepException: domainpart can't be the empty string")
    }
}
