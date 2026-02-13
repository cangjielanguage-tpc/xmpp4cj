// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fullFrom06_01(): Unit {
        let localPart=Localpart.froms("abcs")
        let domainpart=Domainpart.froms("domain")
        let res=Resourcepart.froms("res")
        let fullId=JidCreate.fullFrom(localPart,domainpart,res)
        @Assert(fullId.asEntityFullJidOrThrow() is EntityFullJid)
        try{
            fullId.asDomainFullJidOrThrow()
            @Assert(false)
        }catch(e:IllegalStateException){
            if(e.toString().contains("The JID 'abcs@domain/res' can not be converted to DomainFullJid")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}