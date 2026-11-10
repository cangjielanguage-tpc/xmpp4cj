// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_entityFullFromOrThrowUnchecked_02(): Unit {
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](JidCreate.entityFullFromOrThrowUnchecked("localdomain/resource"))
        @Assert(e.toString(), "IllegalArgumentException: XmppStringprepException: XmppStringprepException caused by 'localdomain/resource': XmppStringprepException: XmppStringprepException caused by 'None@localdomain/resource': XmppStringprepException: localpart can't be None")
    }
}
