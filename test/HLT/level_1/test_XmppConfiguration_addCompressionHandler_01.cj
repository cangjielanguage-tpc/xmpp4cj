// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmppConfiguration{
    //public static func addCompressionHandler(xmppInputOutputStream: XMPPInputOutputStream): Unit
    @TestCase
    func test_XmppConfiguration_addCompressionHandler_01(): Unit {
        var xmppInputOutputStream=ZlibInputOutputStream()
        XmppConfiguration.addCompressionHandler(xmppInputOutputStream)
        var compressionHandlers=XmppConfiguration.getCompressionHandlers()
        @Assert(compressionHandlers.size,2)
        var bb=ByteBuffer()
        var input01=compressionHandlers.get(0).getOrThrow().getInputStream(bb)
        var readOut01=Array<Byte>(10,repeat:0)
        @Assert(input01.read(readOut01)==0,true)
        var input02=compressionHandlers.get(1).getOrThrow().getInputStream(bb)
        var readOut02=Array<Byte>(10,repeat:0)
        @Assert(input02.read(readOut02)==0,true)
    }
}