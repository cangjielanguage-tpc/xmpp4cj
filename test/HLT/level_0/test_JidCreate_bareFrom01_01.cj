// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_bareFrom01_01(): Unit {
        let jid=JidCreate.bareFrom("local@domain/resource")
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isEntityBareJid(),true)
    }
    @TestCase
    func test_JidCreate_bareFrom01_02(): Unit {
        let jid=JidCreate.bareFrom("localdomain/resource")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_bareFrom01_03(): Unit {
        let jid=JidCreate.bareFrom("localdomain")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
    @TestCase
    func test_JidCreate_bareFrom01_04(): Unit {
        let e:XmppStringprepException=@AssertThrows[XmppStringprepException](JidCreate.bareFrom(""))
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")
    }
}