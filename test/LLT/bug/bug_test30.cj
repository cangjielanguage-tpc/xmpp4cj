// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_Jid_asUrlEncodedString_02(): Unit {
        // & * % +
        let jid01 = JidCreate.froms("local", "dom.example", "0123456789")
        @Assert(jid01.asUrlEncodedString(),"local%40dom.example%2F0123456789")
        let jid02 = JidCreate.froms("local", "dom.example", " !\"#$%&'()*+-,.//")
        @Assert(jid02.asUrlEncodedString(),"local%40dom.example%2F+%21%22%23%24%25%26%27%28%29*%2B-%2C.%2F%2F")
        let jid03 = JidCreate.froms("local", "dom.example", ":;<>=?@")
        @Assert(jid03.asUrlEncodedString(),"local%40dom.example%2F%3A%3B%3C%3E%3D%3F%40")
        let jid04 = JidCreate.froms("local", "dom.example", "ABCDEFGHIGKLMNOPQRSTUVWXYZ")
        @Assert(jid04.asUrlEncodedString(),"local%40dom.example%2FABCDEFGHIGKLMNOPQRSTUVWXYZ")
        let jid05 = JidCreate.froms("local", "dom.example", "abcdefghijklmnopqrstuvwxyz")
        @Assert(jid05.asUrlEncodedString(),"local%40dom.example%2Fabcdefghijklmnopqrstuvwxyz")
        let jid06 = JidCreate.froms("local", "dom.example", "[\\]^_`")
        @Assert(jid06.asUrlEncodedString(),"local%40dom.example%2F%5B%5C%5D%5E_%60")
        let jid07 = JidCreate.froms("local", "dom.example", "{}~','...")
        @Assert(jid07.asUrlEncodedString(),"local%40dom.example%2F%7B%7D%7E%27%2C%27...")
    }
}
