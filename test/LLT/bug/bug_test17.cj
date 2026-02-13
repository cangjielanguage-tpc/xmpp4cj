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

    @TestCase
    func test_JidCreate_froms01_02(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.froms("", "domain", ""))
        @Assert("XmppStringprepException: localpart can't be the empty string", e.toString())
    }

    @TestCase
    func test_JidCreate_froms01_03(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.froms("local", "domain", ""))
        @Assert("XmppStringprepException: resourcepart can't be the empty string", e.toString())
    }

    @TestCase
    func test_JidCreate_froms01_04(): Unit {
        let e: MissingDomainpart = @AssertThrows[MissingDomainpart](JidCreate.froms("local", "", "res"))
        @Assert("MissingDomainpart: The provided string does not have a domainpart", e.toString())
    }

    @TestCase
    func test_JidCreate_froms01_05(): Unit {
        var locals = [":", "&", "@", " "]
        for (local in locals) {
            let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.froms(local, "dom.example", "res"))
            @Assert("XmppStringprepException: Localpart must not contain '${local}'", e.toString())
        }
    }

    @TestCase
    func test_JidCreate_froms01_06(): Unit {
        let jid01 = JidCreate.froms(None<String>, "domainJid", None<String>)
        let jid02 = JidCreate.froms("localJid", "domainJid", "resourceJid")
        let jid03 = JidCreate.froms("localJid", "domainJid", None<String>)
        let jid04 = JidCreate.froms(None<String>, "domainJid", "res")
    }
}
