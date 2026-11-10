// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_froms01_04(): Unit {
        var locals: Array<String> = [":", "&", "@", " "]
        for (local in locals) {
            let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.froms(local, "dom.example", "res"))
            @Assert("XmppStringprepException: Localpart must not contain '${local}'", e.toString())
        }
    }
}
