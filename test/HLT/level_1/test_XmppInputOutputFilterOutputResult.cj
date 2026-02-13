// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjXmppInputOutputFilterOutputResult{
    @TestCase
    func test_XmppInputOutputFilterOutputResult_1(): Unit {
        var outputResult01=XmppInputOutputFilterOutputResult.NO_OUTPUT
        var outputResult02=XmppInputOutputFilterOutputResult(ByteBuffer())
        var outputResult03=XmppInputOutputFilterOutputResult(true,ByteBuffer())
        var outputResult04=XmppInputOutputFilterOutputResult(false,ByteBuffer())
        var outputResult05=XmppInputOutputFilterOutputResult(false,None<ByteBuffer>)
        @Assert(outputResult01.pendingFilterData,false)
        @Assert(outputResult02.pendingFilterData,false)
        @Assert(outputResult03.pendingFilterData,true)
        @Assert(outputResult04.pendingFilterData,false)
        @Assert(outputResult05.pendingFilterData,false)
    }
}
