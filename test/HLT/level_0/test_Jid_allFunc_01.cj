// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJid{
    let jid=JidCreate.froms(None<String>,"domainJid",None<String>)
    @TestCase
    func test_Jid_func_01(): Unit {
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
    func test_Jid_func_02(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.getLocalpartOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' has no localpart")
    }
    @TestCase
    func test_Jid_func_03(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityBareJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' can not be converted to EntityBareJid")
    }
    @TestCase
    func test_Jid_func_04(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' can not be converted to EntityFullJid")
    }
    @TestCase
    func test_Jid_func_05(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asEntityJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' can not be converted to EntityJid")
    }
    @TestCase
    func test_Jid_func_06(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' can not be converted to EntityBareJid")
    }
    @TestCase
    func test_Jid_func_07(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.asDomainFullJidOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' can not be converted to DomainFullJid")
    }
    @TestCase
    func test_Jid_func_08(): Unit {
        let e:IllegalStateException=@AssertThrows[IllegalStateException](jid.getResourceOrThrow())
        @Assert(e.toString(),"IllegalStateException: The JID 'domainjid' has no resourcepart")
    }
}