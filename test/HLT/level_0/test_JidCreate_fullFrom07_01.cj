// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fullFrom07_01(): Unit {
        let bareJid=JidCreate.froms("local","domain","res").asBareJid()
        let res=Resourcepart.froms("res")
        let fullId=JidCreate.fullFrom(bareJid,res)
        @Assert(fullId.asEntityFullJidOrThrow() is EntityFullJid)
        try{
            fullId.asDomainFullJidOrThrow()
            @Assert(false)
        }catch(e:IllegalStateException){

            if(e.toString().contains("The JID 'local@domain/res' can not be converted to DomainFullJid")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}