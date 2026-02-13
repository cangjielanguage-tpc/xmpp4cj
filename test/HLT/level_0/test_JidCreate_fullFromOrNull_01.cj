// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate {
    @TestCase
    func test_JidCreate_fullFromOrNull_01(): Unit {
        let fullId = JidCreate.fullFromOrNull("local@domain/res").getOrThrow()

        let entryfullId = fullId.asEntityFullJidOrThrow()
        @Assert(entryfullId is EntityFullJid,true)

        @Assert(entryfullId.getLocalpartOrThrow().toString(),"local")
        @Assert(entryfullId.getDomain().toString(),"domain")
        @Assert(entryfullId.getResourceOrThrow().toString(),"res")
        try{
            fullId.asDomainFullJidOrThrow()
        }catch(e:IllegalStateException){
            if(e.toString().contains("IllegalStateException: The JID 'local@domain/res' can not be converted to DomainFullJid")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_JidCreate_fullFromOrNull_02(): Unit {
        @Assert(JidCreate.fullFromOrNull("local@domain").isNone(),true)
    }
    @TestCase
    func test_JidCreate_fullFromOrNull_03(): Unit {
        let fullId = JidCreate.fullFromOrNull("domain/res").getOrThrow()

        let domainfullId = fullId.asDomainFullJidOrThrow()
        @Assert(domainfullId is DomainFullJid,true)
        @Assert(domainfullId.getDomain().toString(),"domain")
        @Assert(domainfullId.getResourceOrThrow().toString(),"res")
        try{
            fullId.asEntityFullJidOrThrow()
        }catch(e:IllegalStateException){
            if(e.toString().contains("IllegalStateException: The JID 'domain/res' can not be converted to EntityFullJid")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}
