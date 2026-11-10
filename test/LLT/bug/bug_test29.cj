// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_Jid_asUrlEncodedString_02(): Unit {
        var jid02 = JidCreate.froms("local", "dom.example", " !\"#$%&'()*+-,.//")
        @Assert(jid02.asUrlEncodedString(), "local%40dom.example%2F+%21%22%23%24%25%26%27%28%29*%2B-%2C.%2F%2F")
    }
}
