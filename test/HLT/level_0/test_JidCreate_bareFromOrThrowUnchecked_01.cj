// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjJidCreate{
    @TestCase
    func test_JidCreate_bareFromOrThrowUnchecked_01(): Unit {
        let jid=JidCreate.bareFromOrThrowUnchecked("local@domain/resource")
        @Assert(jid.asEntityBareJidOrThrow().toString(),"local@domain")
    }
    @TestCase
    func test_JidCreate_bareFromOrThrowUnchecked_02(): Unit {
        let jid=JidCreate.bareFromOrThrowUnchecked("localdomain/resource")
        try{
            jid.asEntityBareJidOrThrow()
            @Assert(false)
        }catch(e:IllegalStateException){

            if(e.toString().contains("IllegalStateException: The JID 'localdomain' can not be converted to EntityBareJid")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_JidCreate_bareFromOrThrowUnchecked_03(): Unit {
        let jid=JidCreate.bareFromOrThrowUnchecked("localdomain")
        try{
            jid.asEntityBareJidOrThrow()
            @Assert(false)
        }catch(e:IllegalStateException){

            if(e.toString().contains("IllegalStateException: The JID 'localdomain' can not be converted to EntityBareJid")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @TestCase
    func test_JidCreate_bareFromOrThrowUnchecked_04(): Unit {
        try{
            let jid=JidCreate.bareFromOrThrowUnchecked("")
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