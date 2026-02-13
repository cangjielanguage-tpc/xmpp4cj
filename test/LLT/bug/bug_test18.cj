// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_fromOrThrowUnchecked_04(): Unit {
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](JidCreate.fromOrThrowUnchecked(""))
        @Assert("IllegalArgumentException: XmppStringprepException: XmppStringprepException caused by '': MissingDomainpart: The provided string does not have a domainpart", e.toString())
    }
}
