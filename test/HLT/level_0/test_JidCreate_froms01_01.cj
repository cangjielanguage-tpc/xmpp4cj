// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{

    @TestCase
    func test_JidCreate_froms01_01(): Unit {
        let e:MissingDomainpart=@AssertThrows[MissingDomainpart](JidCreate.froms(None<String>,"",None<String>))
        @Assert(e.toString(),"MissingDomainpart: The provided string does not have a domainpart")

    }
    @TestCase
    func test_JidCreate_froms01_02(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.froms("","domain",""))
        @Assert(e.toString(),"XmppStringprepException: localpart can't be the empty string")

    }
    @TestCase
    func test_JidCreate_froms01_03(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.froms("local","domain",""))
        @Assert(e.toString(),"XmppStringprepException: resourcepart can't be the empty string")

    }
    @TestCase
    func test_JidCreate_froms01_04(): Unit {
        let e:MissingDomainpart=@AssertThrows[MissingDomainpart](JidCreate.froms("local","","res"))
        @Assert(e.toString(),"MissingDomainpart: The provided string does not have a domainpart")

    }
    @TestCase
    func test_JidCreate_froms01_05(): Unit {
        var locals=[":","&","@"," "]
        var jid = JidCreate.froms(None<String>, "dom.example", None<String>)
        for (local in locals){
            let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.froms(local, "dom.example", "res"))

            @Assert(e.toString(),"XmppStringprepException: Localpart must not contain '${local}'")
        }
    }

    @TestCase
    func test_JidCreate_froms01_06(): Unit {
        let jid01=JidCreate.froms(None<String>,"domainJid",None<String>)
        let jid02=JidCreate.froms("localJid","domainJid","resourceJid")
        let jid03=JidCreate.froms("localJid", "domainJid", None<String>)
        let jid04=JidCreate.froms(None<String>, "domainJid","res")
    }
}