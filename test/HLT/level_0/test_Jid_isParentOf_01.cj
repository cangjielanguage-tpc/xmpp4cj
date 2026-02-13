// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJid {
    @TestCase
    func test_Jid_isParentOf01_01(): Unit {
        let jid01 = JidCreate.froms(None<String>, "dom.example", None<String>)
        let jid02 = JidCreate.froms(None<String>, "dom.example", None<String>)
        let jid03 = JidCreate.froms(None<String>, "dom.example", "res")
        let jid04 = JidCreate.froms(None<String>, "dom.example", "res")
        let jid05 = JidCreate.froms("local", "dom.example", None<String>)
        let jid06 = JidCreate.froms("local", "dom.example", None<String>)
        let jid07 = JidCreate.froms("local", "dom.example", "res")
        let jid08 = JidCreate.froms("local", "dom.example", "res")
        @Assert(jid01.isParentOf(jid02),true)
        @Assert(jid01.isParentOf(jid03),true)
        @Assert(jid01.isParentOf(jid05),true)
        @Assert(jid01.isParentOf(jid07),true)

        @Assert(jid03.isParentOf(jid01),false)
        @Assert(jid03.isParentOf(jid03),true)
        @Assert(jid03.isParentOf(jid05),false)
        @Assert(jid03.isParentOf(jid07),false)

        @Assert(jid05.isParentOf(jid01),false)
        @Assert(jid05.isParentOf(jid03),false)
        @Assert(jid05.isParentOf(jid05),true)
        @Assert(jid05.isParentOf(jid07),true)

        @Assert(jid07.isParentOf(jid01),false)
        @Assert(jid07.isParentOf(jid03),false)
        @Assert(jid07.isParentOf(jid05),false)
        @Assert(jid07.isParentOf(jid07),true)
    }
    @TestCase
    func test_Jid_isParentOf02_01(): Unit {
        let jid01 = JidCreate.froms(None<String>, "dom.example", None<String>)
        let jid02 = JidCreate.froms(None<String>, "dom.example", "res")
        let jid03 = JidCreate.froms("local", "dom.example", None<String>)
        let entryBareJid01=jid03.asEntityBareJidOrThrow()
        let jid04 = JidCreate.froms("local", "dom.example:80", None<String>)
        let entryBareJid02=jid04.asEntityBareJidOrThrow()
        let jid05 = JidCreate.froms("local123.wbew", "dom.example", "res&a=b")
        let entryBareJid03=jid05.asEntityBareJidOrThrow()

        @Assert(jid01.isParentOf(entryBareJid01),true)
        @Assert(jid01.isParentOf(entryBareJid02),false)
        @Assert(jid01.isParentOf(entryBareJid03),true)

        @Assert(jid02.isParentOf(entryBareJid01),false)
        @Assert(jid02.isParentOf(entryBareJid02),false)
        @Assert(jid02.isParentOf(entryBareJid03),false)

        @Assert(jid03.isParentOf(entryBareJid01),true)
        @Assert(jid03.isParentOf(entryBareJid02),false)
        @Assert(jid03.isParentOf(entryBareJid03),false)

        @Assert(jid04.isParentOf(entryBareJid01),false)
        @Assert(jid04.isParentOf(entryBareJid02),true)
        @Assert(jid04.isParentOf(entryBareJid03),false)

        @Assert(jid05.isParentOf(entryBareJid01),false)
        @Assert(jid05.isParentOf(entryBareJid02),false)
        @Assert(jid05.isParentOf(entryBareJid03),false)
    }
    @TestCase
    func test_Jid_isParentOf_03(): Unit {
        let jid01 = JidCreate.froms(None<String>, "dom.example", None<String>)
        let jid02 = JidCreate.froms(None<String>, "dom.example", "res")
        let jid03 = JidCreate.froms("local", "dom.example", None<String>)
        let jid04 = JidCreate.froms("local", "dom.example:80", None<String>)

        let jid05 = JidCreate.froms("local", "dom.example", "res")
        let entryFullJid01=jid05.asEntityFullJidOrThrow()

        let jid06 = JidCreate.froms("local01", "dom.example", "res")
        let entryFullJid02=jid06.asEntityFullJidOrThrow()

        let jid07 = JidCreate.froms("local", "dom.example09", "res")
        let entryFullJid03=jid07.asEntityFullJidOrThrow()

        let jid08 = JidCreate.froms("local", "dom.example", "res02")
        let entryFullJid04=jid08.asEntityFullJidOrThrow()

        @Assert(jid01.isParentOf(entryFullJid01),true)
        @Assert(jid01.isParentOf(entryFullJid02),true)
        @Assert(jid01.isParentOf(entryFullJid03),false)
        @Assert(jid01.isParentOf(entryFullJid04),true)

        @Assert(jid02.isParentOf(entryFullJid01),false)
        @Assert(jid02.isParentOf(entryFullJid02),false)
        @Assert(jid02.isParentOf(entryFullJid03),false)
        @Assert(jid02.isParentOf(entryFullJid04),false)

        @Assert(jid03.isParentOf(entryFullJid01),true)
        @Assert(jid03.isParentOf(entryFullJid02),false)
        @Assert(jid03.isParentOf(entryFullJid03),false)
        @Assert(jid03.isParentOf(entryFullJid04),true)

        @Assert(jid04.isParentOf(entryFullJid01),false)
        @Assert(jid04.isParentOf(entryFullJid02),false)
        @Assert(jid04.isParentOf(entryFullJid03),false)
        @Assert(jid04.isParentOf(entryFullJid04),false)

        @Assert(jid05.isParentOf(entryFullJid01),true)
        @Assert(jid05.isParentOf(entryFullJid02),false)
        @Assert(jid05.isParentOf(entryFullJid03),false)
        @Assert(jid05.isParentOf(entryFullJid04),false)
    }
    @TestCase
    func test_Jid_isParentOf_04(): Unit {
        let jid01 = JidCreate.froms(None<String>, "dom.example", None<String>)
        let jid02 = JidCreate.froms(None<String>, "dom.example", "res")
        let jid03 = JidCreate.froms("local", "dom.example", None<String>)
        let domainBareJid01=jid03.asDomainBareJid()
        let jid04 = JidCreate.froms("local", "dom.example:80", None<String>)
        let domainBareJid02=jid04.asDomainBareJid()
        let jid05 = JidCreate.froms("local123.wbew", "dom.example", "res&a=b")
        let domainBareJid03=jid05.asDomainBareJid()

        @Assert(jid01.isParentOf(domainBareJid01),true)
        @Assert(jid01.isParentOf(domainBareJid02),false)
        @Assert(jid01.isParentOf(domainBareJid03),true)

        @Assert(jid02.isParentOf(domainBareJid01),false)
        @Assert(jid02.isParentOf(domainBareJid02),false)
        @Assert(jid02.isParentOf(domainBareJid03),false)

        @Assert(jid03.isParentOf(domainBareJid01),false)
        @Assert(jid03.isParentOf(domainBareJid02),false)
        @Assert(jid03.isParentOf(domainBareJid03),false)

        @Assert(jid04.isParentOf(domainBareJid01),false)
        @Assert(jid04.isParentOf(domainBareJid02),false)
        @Assert(jid04.isParentOf(domainBareJid03),false)

        @Assert(jid05.isParentOf(domainBareJid01),false)
        @Assert(jid05.isParentOf(domainBareJid02),false)
        @Assert(jid05.isParentOf(domainBareJid03),false)
    }
    @TestCase
    func test_Jid_isParentOf_05(): Unit {

        let jid01 = JidCreate.froms(None<String>, "dom.example", None<String>)
        let jid02 = JidCreate.froms(None<String>, "dom.example", "res")
        let domainFullJid02=jid02.asDomainFullJidOrThrow()
        let jid03 = JidCreate.froms("local", "dom.example", None<String>)
        let jid04 = JidCreate.froms("local", "dom.example:80", None<String>)
        let jid05 = JidCreate.froms("local123.wbew", "dom.example", "res&a=b")


        @Assert(jid01.isParentOf(domainFullJid02),true)
        @Assert(jid02.isParentOf(domainFullJid02),true)
        @Assert(jid03.isParentOf(domainFullJid02),false)
        @Assert(jid04.isParentOf(domainFullJid02),false)
        @Assert(jid05.isParentOf(domainFullJid02),false)

    }
}
