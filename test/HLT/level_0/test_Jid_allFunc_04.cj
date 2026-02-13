// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJid {
    let jid=JidCreate.froms(None<String>, "domainJid","resourceJid")
    @TestCase
    func test_Jid_func04_01(): Unit {
        @Assert(jid.getDomain().toString(),"domainjid")
        @Assert(jid.asUnescapedString(),"domainjid/resourceJid")
        @Assert(jid.asUrlEncodedString(),"domainjid%2FresourceJid")
        @Assert(jid.asBareJid().toString(),"domainjid")
        @Assert(jid.asDomainBareJid().getDomain().toString(),"domainjid")
        @Assert(jid.isEntityJid(),false)
        @Assert(jid.isEntityBareJid(),false)
        @Assert(jid.isEntityFullJid(),false)
        @Assert(jid.isDomainBareJid(),false)
        @Assert(jid.isDomainFullJid(),true)
        @Assert(jid.hasNoResource(),false)
        @Assert(jid.hasResource(),true)
        @Assert(jid.hasLocalpart(),false)
        @Assert(jid.asEntityBareJidIfPossible().isNone(),true)
        @Assert(jid.asEntityFullJidIfPossible().isNone(),true)
        @Assert(jid.asEntityJidIfPossible().isNone(),true)
        @Assert(jid.asFullJidIfPossible().getOrThrow().toString(),"domainjid/resourceJid")
        @Assert(jid.asDomainFullJidIfPossible().getOrThrow().toString(),"domainjid/resourceJid")
        @Assert(jid.getResourceOrNull().getOrThrow().toString(),"resourceJid")
        @Assert(jid.getResourceOrEmpty().toString(),"resourceJid")
        @Assert(jid.getLocalpartOrNull().isNone(),true)
        @Assert(jid.getResourceOrThrow().toString(),"resourceJid")
    }
    @TestCase
    func test_Jid_func04_02(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid/resourceJid' can not be converted to EntityFullJid")
    }
    @TestCase
    func test_Jid_func04_03(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid/resourceJid' can not be converted to EntityBareJid")
    }
    @TestCase
    func test_Jid_func04_04(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.getLocalpartOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid/resourceJid' has no localpart")
    }
    @TestCase
    func test_Jid_func04_05(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityBareJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid/resourceJid' can not be converted to EntityBareJid")
    }
    @TestCase
    func test_Jid_func04_06(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid/resourceJid' can not be converted to EntityFullJid")
    }
    @TestCase
    func test_Jid_func04_07(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid/resourceJid' can not be converted to EntityJid")
    }
}
