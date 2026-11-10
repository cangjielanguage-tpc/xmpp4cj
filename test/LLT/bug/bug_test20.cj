// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_fromUnescapedOrNull_04(): Unit {
        @Assert(JidCreate.fromUnescapedOrNull("").isNone(),true)
    }
}
