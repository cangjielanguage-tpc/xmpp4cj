// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class JidTest {
    @TestCase
    public func testJidIsParentOf(): Unit {
        let domainBareJid = JidCreate.froms("dom.example")
        let domainFullJid = JidCreate.froms("dom.example/res")
        let bareJid = JidCreate.froms("loc@dom.example")
        let fullJid = JidCreate.froms("loc@dom.example/res")
        Assert.assertTrue(domainBareJid.isParentOf(domainBareJid))
        Assert.assertTrue(domainBareJid.isParentOf(domainFullJid))
        Assert.assertTrue(domainBareJid.isParentOf(bareJid))
        Assert.assertTrue(domainBareJid.isParentOf(fullJid))
        Assert.assertFalse(domainFullJid.isParentOf(domainBareJid))
        Assert.assertTrue(domainFullJid.isParentOf(domainFullJid))
        Assert.assertFalse(domainFullJid.isParentOf(bareJid))
        Assert.assertFalse(domainFullJid.isParentOf(fullJid))
        Assert.assertFalse(bareJid.isParentOf(domainBareJid))
        Assert.assertFalse(bareJid.isParentOf(domainFullJid))
        Assert.assertTrue(bareJid.isParentOf(bareJid))
        Assert.assertTrue(bareJid.isParentOf(fullJid))
        Assert.assertFalse(fullJid.isParentOf(domainBareJid))
        Assert.assertFalse(fullJid.isParentOf(domainFullJid))
        Assert.assertFalse(fullJid.isParentOf(bareJid))
        Assert.assertTrue(fullJid.isParentOf(fullJid))
    }

    public func stripFinalDot(): Unit {
        let domain = "foo.bar."
        let jid = JidCreate.domainBareFrom(domain)
        Assert.assertEquals("foo.bar", jid.toString())
    }
}
