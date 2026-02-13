// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJid {
    @TestCase
    func test_Jid_asUrlEncodedString_01(): Unit {
        let jid01 = JidCreate.froms(None<String>, "dom.example", None<String>)
        @Assert(jid01.asUrlEncodedString(),"dom.example")
        let jid02 = JidCreate.froms(None<String>, "dom.example", "res")
        @Assert(jid02.asUrlEncodedString(),"dom.example%2Fres")
        let jid03 = JidCreate.froms("local", "dom.example", None<String>)
        @Assert(jid03.asUrlEncodedString(),"local%40dom.example")
        let jid04 = JidCreate.froms("local", "dom.example", "res")
        @Assert(jid04.asUrlEncodedString(),"local%40dom.example%2Fres")
    }
    @TestCase
    func test_Jid_asUrlEncodedString_02(): Unit {
        let jid01 = JidCreate.froms("local", "dom.example","0123456789")
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
