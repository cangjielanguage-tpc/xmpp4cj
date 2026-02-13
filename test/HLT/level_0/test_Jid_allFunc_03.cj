// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJid {
    let jid = JidCreate.froms("localJid", "domainJid", None<String>)
    @TestCase
    func test_Jid_func03_01(): Unit {
        @Assert(jid.getDomain().toString(),"domainjid")
        @Assert(jid.asUnescapedString(),"localjid@domainjid")
        @Assert(jid.asUrlEncodedString(),"localjid%40domainjid")
        @Assert(jid.asBareJid().toString(),"localjid@domainjid")
        @Assert(jid.asDomainBareJid().getDomain().toString(),"domainjid")

        @Assert(jid.isEntityJid(),true)
        @Assert(jid.isEntityBareJid(),true)
        @Assert(jid.isEntityFullJid(),false)
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isDomainFullJid(),false)
        @Assert(jid.hasNoResource(),true)
        @Assert(jid.hasResource(),false)
        @Assert(jid.hasLocalpart(),true)
        @Assert(jid.asEntityBareJidIfPossible().getOrThrow().toString(),"localjid@domainjid")
        @Assert(jid.asEntityFullJidIfPossible().isNone(),true)
        @Assert(jid.asEntityJidIfPossible().getOrThrow().toString(),"localjid@domainjid")
        @Assert(jid.asFullJidIfPossible().isNone(),true)
        @Assert(jid.asDomainFullJidIfPossible().isNone(),true)
        @Assert(jid.getResourceOrNull().isNone(),true)
        @Assert(jid.getResourceOrEmpty().toString(),"")
        @Assert(jid.getLocalpartOrNull().getOrThrow().toString(),"localjid")
        @Assert(jid.getLocalpartOrThrow().toString(),"localjid")
        @Assert(jid.asEntityBareJidOrThrow().toString(),"localjid@domainjid")
        @Assert(jid.asEntityJidOrThrow().toString(),"localjid@domainjid")
    }
    @TestCase
    func test_Jid_func03_02(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.getResourceOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'localjid@domainjid' has no resourcepart")
    }
    @TestCase
    func test_Jid_func03_03(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'localjid@domainjid' can not be converted to EntityFullJid")
    }
    @TestCase
    func test_Jid_func03_04(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'localjid@domainjid' can not be converted to EntityBareJid")
    }
    @TestCase
    func test_Jid_func03_05(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asDomainFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'localjid@domainjid' can not be converted to DomainFullJid")
    }
}
