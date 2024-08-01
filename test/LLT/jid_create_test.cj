// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class JidCreateTest {
    @TestCase
    public func bareFromThrowTest(): Unit {
        let notABareJid = "example.org/test"
        try {
            let jid = JidCreate.entityBareFrom(notABareJid)
            Assert.fail(jid.toString() + " should never been created")
        } catch (e: XmppStringprepException) {
            Assert.assertEquals(notABareJid, e.getCausingString())
        }
    }

    @TestCase
    public func bareFromDomainJidTest(): Unit {
        let domainJid = "pubsub.hamlet.lit"
        let jid = JidCreate.bareFrom(domainJid)
        Assert.assertTrue(jid is DomainBareJid)
    }

    @TestCase
    public func fullFromThrowTest(): Unit {
        let notAFullJid = "user@example.org/"
        try {
            let jid = JidCreate.entityFullFrom(notAFullJid)
            Assert.fail(jid.toString() + " should never been created")
        } catch (e: XmppStringprepException) {
            Assert.assertEquals(notAFullJid, e.getCausingString())
        }
    }

    @TestCase
    public func domainBareThrowTest(): Unit {
        let notADomainBareJid = ""
        try {
            let jid = JidCreate.domainBareFrom(notADomainBareJid)
            Assert.fail(jid.toString() + " should never been created")
        } catch (e: XmppStringprepException) {
            Assert.assertEquals(notADomainBareJid, e.getCausingString())
        }
    }

    @TestCase
    public func domainFullThrowTest(): Unit {
        let notADomainFullJid = "example.org"
        try {
            let jid = JidCreate.domainFullFrom(notADomainFullJid)
            Assert.fail(jid.toString() + " should never been created")
        } catch (e: XmppStringprepException) {
            Assert.assertEquals(notADomainFullJid, e.getCausingString())
        }
    }

    @TestCase
    public func entityBareFromUnescapedTest(): Unit {
        let entityBareJid = JidCreate.entityBareFromUnescaped("foo@boo@example.org/baz")
        let domainpart = entityBareJid.getDomain()
        Assert.assertEquals(Domainpart.froms("boo@example.org").toString(), domainpart.toString())
        let localpart = entityBareJid.getLocalpart()
        Assert.assertEquals(Localpart.froms("foo").toString(), localpart.toString())
    }

    @TestCase
    public func entityFullFromComplexTest(): Unit {
        let entityFullJid = JidCreate.entityFullFrom("foo@boo@example.org/bar@baz")
        let domainpart = entityFullJid.getDomain()
        Assert.assertEquals(Domainpart.froms("boo@example.org").toString(), domainpart.toString())
        let localpart = entityFullJid.getLocalpart()
        Assert.assertEquals(Localpart.froms("foo").toString(), localpart.toString())
        let resourcepart = entityFullJid.getResourcepart()
        Assert.assertEquals(Resourcepart.froms("bar@baz").toString(), resourcepart.toString())
    }

    @TestCase
    public func entityFullFromUnescapedComplexTest(): Unit {
        let entityFullJid = JidCreate.entityFullFromUnescaped("foo@boo@example.org/bar@baz")
        let domainpart = entityFullJid.getDomain()
        Assert.assertEquals(Domainpart.froms("boo@example.org"), domainpart)
        let localpart = entityFullJid.getLocalpart()
        Assert.assertEquals(Localpart.froms("foo"), localpart)
        let resourcepart = entityFullJid.getResourcepart()
        Assert.assertEquals(Resourcepart.froms("bar@baz"), resourcepart)
    }

    @TestCase
    public func entityFromUnescapedBareTest(): Unit {
        let entityJid = JidCreate.entityFromUnescaped("d'artagnan@musketeers.lit")
        let domainpart = entityJid.getDomain()
        Assert.assertEquals(Domainpart.froms("musketeers.lit"), domainpart)
        let localpart = entityJid.getLocalpart()
        Assert.assertEquals(Localpart.froms("d\\27artagnan"), localpart)
        Assert.assertEquals(localpart, Localpart.fromUnescaped("d\'artagnan"))
    }

    @TestCase
    public func entityFromUnescapedFullTest(): Unit {
        let entityBareJid = JidCreate.entityFromUnescaped("d\'artagnan@gascon.fr/elder")
        let domainpart = entityBareJid.getDomain()
        Assert.assertEquals(Domainpart.froms("gascon.fr"), domainpart)
        let resourcepart = entityBareJid.getResourceOrThrow()
        Assert.assertEquals(Resourcepart.froms("elder"), resourcepart)
        let localpart = entityBareJid.getLocalpart()
        Assert.assertEquals(Localpart.froms("d\\27artagnan"), localpart)
    }

    @TestCase
    public func jidResourcepartWithAtSignTest(): Unit {
        let jid = JidCreate.froms("a.example.com/b@example.net")
        Assert.assertEquals(Domainpart.froms("a.example.com"), jid.getDomain())
        Assert.assertEquals(Resourcepart.froms("b@example.net"), jid.getResourceOrNull()())
    }

    @TestCase
    public func emptyLocalpartShouldThrowTest(): Unit {
        let invalidJid = "@emptyLocalpartShouldThrowTest.org"
        Assertions.assertThrows(TypeInfo.of<XmppStringprepException>(), {=> JidCreate.froms(invalidJid)})
    }

    @TestCase
    public func noCachedJidShadowingLocalpartTest(): Unit {
        let validJid = "noCachedJidShadowingLocalpartTest.org"
        JidCreate.froms(validJid)
        let invalidJid = "@noCachedJidShadowingLocalpartTest.org"
        Assertions.assertThrows(TypeInfo.of<XmppStringprepException>(), {=> JidCreate.froms(invalidJid)})
    }

    @TestCase
    public func leadingAndTrailingWhitespaceTest(): Unit {
        let invalidJid = "  foo@leadingAndTrailingWhitespaceTest.org  "
        Assertions.assertThrows(TypeInfo.of<XmppStringprepException>(), {=> JidCreate.froms(invalidJid)})
        let invalidJid2 = "  foo@leadingAndTrailingWhitespaceTest.org/bar  "
        Assertions.assertThrows(TypeInfo.of<XmppStringprepException>(), {=> JidCreate.froms(invalidJid2)})
    }
}
