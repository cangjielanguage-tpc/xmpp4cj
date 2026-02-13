// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.sasl.*
import std.time.*
import std.net.*
@Test
public class TestXMPPTCPConnection{
    let XmppTestServerHostName = "xmpp.testserver"
    @Skip  //标准库bug
    @TestCase
    func test_init01_01(): Unit { 
        let connection = XMPPTCPConnection("test2@xmpp.testserver", "123456")
        try{
            connection.connect()
            @Assert(false)
        }catch(e:XmppWrappedException){
            println(e.toString())
            if(e.toString().contains("XmppWrappedException: TLS handshake failed (client): certificate verify failed (134), TLS alert unknown CA(F)")){
                 @Assert(true)
            }else{
                @Assert(false)
            }
        }catch(e:Xmpp4cjException){
            println(e.toString())
            if(e.toString().contains("Xmpp4cjException: No response received within reply timeout")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
    @Skip  //标准库bug
    @TestCase
    func test_init01_02(): Unit {
        let connection = XMPPTCPConnection("testerror@xmpp.testserver", "123456")
        try{
            connection.connect()
            @Assert(false)
        }catch(e:XmppWrappedException){
            println(e.toString())
            if(e.toString().contains("XmppWrappedException: TLS handshake failed (client): certificate verify failed (134), TLS alert unknown CA(F)")){

                @Assert(true)
            }else{
                @Assert(false)
            }
        }catch(e:Xmpp4cjException){
             println(e.toString())
            if(e.toString().contains("Xmpp4cjException: No response received within reply timeout")){

                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}

