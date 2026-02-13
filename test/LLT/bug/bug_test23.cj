// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_bareFromUrlEncoded_02(): Unit {
        let jid = JidCreate.bareFromUrlEncoded("xmpp:localdomain/resource")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }

    @TestCase
    func test_JidCreate_bareFromUrlEncoded_03(): Unit {
        let jid = JidCreate.bareFromUrlEncoded("xmpp:localdomain")
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isEntityBareJid(),false)
    }
}
