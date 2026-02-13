// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_fullFrom04_01(): Unit {
        let xmppcontext=XmppContext.getDefaultContext()
        try{
            JidCreate.fullFrom(None<String>,"","res",xmppcontext)
            @Assert(false)
        }catch(e:XmppStringprepException){
            //
            if(e.toString().contains("XmppStringprepException: XmppStringprepException caused by 'None@/res': XmppStringprepException: domainpart can't be the empty string")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}