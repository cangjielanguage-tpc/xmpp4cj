// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    let jid = JidCreate.froms(None<String>, "domainJid", None<String>)

    @TestCase
    func test_JidCreate_func_01(): Unit {
        @Assert(jid.getDomain().toString(),"domainjid")
        @Assert(jid.asUnescapedString(),"domainjid")
        @Assert(jid.asUrlEncodedString(),"domainjid")
        @Assert(jid.asBareJid().getDomain().toString(),"domainjid")
        @Assert(jid.asDomainBareJid().getDomain().toString(),"domainjid")

        @Assert(jid.isEntityJid(),false)
        @Assert(jid.isEntityBareJid(),false)
        @Assert(jid.isEntityFullJid(),false)
        @Assert(jid.isDomainBareJid(),true)
        @Assert(jid.isDomainFullJid(),false)
        @Assert(jid.hasNoResource(),true)
        @Assert(jid.hasResource(),false)
        @Assert(jid.hasLocalpart(),false)

        @Assert(jid.asEntityBareJidIfPossible().isNone(),true)
        @Assert(jid.asEntityFullJidIfPossible().isNone(),true)
        @Assert(jid.asEntityJidIfPossible().isNone(),true)
        @Assert(jid.asFullJidIfPossible().isNone(),true)

        @Assert(jid.asDomainFullJidIfPossible().isNone(),true)
        @Assert(jid.getResourceOrNull().isNone(),true)
        @Assert(jid.getResourceOrEmpty().toString(),"")
        @Assert(jid.getLocalpartOrNull().isNone(),true)
    }

    @TestCase
    func test_JidCreate_func_02(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.getLocalpartOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' has no localpart", e.toString())
    }

    @TestCase
    func test_JidCreate_func_03(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.asEntityBareJidOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' can not be converted to EntityBareJid", e.toString())
    }

    @TestCase
    func test_JidCreate_func_04(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.asEntityFullJidOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' can not be converted to EntityFullJid", e.toString())
    }

    @TestCase
    func test_JidCreate_func_05(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.asEntityJidOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' can not be converted to EntityJid", e.toString())
    }

    @TestCase
    func test_JidCreate_func_06(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.asFullJidOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' can not be converted to EntityBareJid", e.toString())
    }

    @TestCase
    func test_JidCreate_func_07(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.asDomainFullJidOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' can not be converted to DomainFullJid", e.toString())
    }

    @TestCase
    func test_JidCreate_func_08(): Unit {
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.getResourceOrThrow())
        @Assert("IllegalStateException: The JID 'domainjid' has no resourcepart", e.toString())
    }
}
