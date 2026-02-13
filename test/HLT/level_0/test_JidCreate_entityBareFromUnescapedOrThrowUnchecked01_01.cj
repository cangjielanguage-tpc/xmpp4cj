// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_entityBareFromUnescapedOrThrowUnchecked01_01(): Unit {
        let jid=JidCreate.entityBareFromUnescapedOrThrowUnchecked("local@domain/resource")
        let bareJid=jid.asBareJid()
        @Assert(bareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(bareJid.getDomain().toString(),"domain")
        @Assert(bareJid.getResourceOrNull().isNone(),true)

        let entryBareJid=jid.asEntityBareJidOrThrow()
        @Assert(entryBareJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryBareJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)

        let entryFullJid=jid.asEntityFullJidIfPossible()
        @Assert(entryFullJid.isNone(),true)


        //let entryJid=jid.asEntityJidIfPossible()
        let entryJid=jid.asEntityJidOrThrow()
        @Assert(entryJid.getLocalpartOrThrow().toString(),"local")
        @Assert(entryJid.getDomain().toString(),"domain")
        @Assert(entryBareJid.getResourceOrNull().isNone(),true)
        //@Assert(entryJid.isNone(),true)

        let fullJid=jid.asFullJidIfPossible()
        @Assert(fullJid.isNone(),true)

        let domainbareJid=jid.asDomainBareJid()
        @Assert(domainbareJid.getLocalpartOrNull().isNone(),true)
        @Assert(domainbareJid.getDomain().toString(),"domain")
        @Assert(domainbareJid.getResourceOrNull().isNone(),true)

        let domainfullJid=jid.asDomainFullJidIfPossible()
        @Assert(domainfullJid.isNone(),true)
    }
    @TestCase
    func test_JidCreate_entityBareFromUnescapedOrThrowUnchecked01_02(): Unit {
        try{
            JidCreate.entityBareFromUnescapedOrThrowUnchecked("localdomain/resource")
            @Assert(false)
        }catch(e:IllegalArgumentException){

            if(e.toString().contains("IllegalArgumentException: XmppStringprepException caused by 'localdomain/resource': XmppStringprepException: localpart can't be None")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_JidCreate_entityBareFromUnescapedOrThrowUnchecked01_03(): Unit {
        try{
            JidCreate.entityBareFromUnescapedOrThrowUnchecked("localdomain")
            @Assert(false)
        }catch(e:IllegalArgumentException){

            if(e.toString().contains("IllegalArgumentException: XmppStringprepException caused by 'localdomain': XmppStringprepException: localpart can't be None")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_JidCreate_entityBareFromUnescapedOrThrowUnchecked01_04(): Unit {
        try{
            JidCreate.entityBareFromUnescapedOrThrowUnchecked("")
            @Assert(false)
        }catch(e:IllegalArgumentException){

            if(e.toString().contains("IllegalArgumentException: XmppStringprepException caused by '': XmppStringprepException: domainpart can't be the empty string")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}