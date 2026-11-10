// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import stdx.encoding.url.*

@Test
public class TestXmpp4cjJidCreateFroms {
    let jid = JidCreate.froms("localJid", "domainJid", "resourceJid")
    @TestCase
    func test_JidCreate_func_01(): Unit {
        @Assert(jid.getDomain().toString(),"domainjid")
        @Assert(jid.asUnescapedString(),"localjid@domainjid/resourceJid")
        @Assert(jid.asUrlEncodedString(),"localjid%40domainjid%2FresourceJid")
        @Assert(jid.asBareJid().toString(),"localjid@domainjid")
        @Assert(jid.asDomainBareJid().getDomain().toString(),"domainjid")

        @Assert(jid.isEntityJid(),true)
        @Assert(jid.isEntityBareJid(),false)
        @Assert(jid.isEntityFullJid(),true)
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isDomainFullJid(),false)
        @Assert(jid.hasNoResource(),false)
        @Assert(jid.hasResource(),true)
        @Assert(jid.hasLocalpart(),true)

        @Assert(jid.asEntityBareJidIfPossible().getOrThrow().toString(),"localjid@domainjid")
        @Assert(jid.asEntityFullJidIfPossible().getOrThrow().toString(),"localjid@domainjid/resourceJid")
        @Assert(jid.asEntityJidIfPossible().getOrThrow().toString(),"localjid@domainjid/resourceJid")
        @Assert(jid.asFullJidIfPossible().getOrThrow().toString(),"localjid@domainjid/resourceJid")

        @Assert(jid.asDomainFullJidIfPossible().isNone(),true)
        @Assert(jid.getResourceOrNull().getOrThrow().toString(),"resourceJid")
        @Assert(jid.getResourceOrEmpty().toString(),"resourceJid")
        @Assert(jid.getLocalpartOrNull().getOrThrow().toString(),"localjid")
        @Assert(jid.getLocalpartOrThrow().toString(),"localjid")
        @Assert(jid.getResourceOrThrow().toString(),"resourceJid")
        @Assert(jid.asEntityBareJidOrThrow().toString(),"localjid@domainjid")
        @Assert(jid.asEntityFullJidOrThrow().toString(),"localjid@domainjid/resourceJid")
        @Assert(jid.asEntityJidOrThrow().toString(),"localjid@domainjid/resourceJid")
        @Assert(jid.asFullJidOrThrow().toString(),"localjid@domainjid/resourceJid")
    }

    @TestCase
    func test_JidCreate_froms01_01(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.froms("", "domain", ""))
        @Assert("XmppStringprepException: localpart can't be the empty string", e.toString())
    }
}
