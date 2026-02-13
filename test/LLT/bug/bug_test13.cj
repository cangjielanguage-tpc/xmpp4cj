// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_froms01_01(): Unit {
        let e: MissingDomainpart = @AssertThrows[MissingDomainpart](JidCreate.froms(None<String>,"",None<String>))
        @Assert("MissingDomainpart: The provided string does not have a domainpart", e.toString())
    }
}
