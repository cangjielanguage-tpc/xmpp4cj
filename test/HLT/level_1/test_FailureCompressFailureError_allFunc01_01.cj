// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjFailureCompressFailureError{

    @TestCase
    func test_FailureCompressFailureError_fromString_1_01(): Unit {
        var actCompressFailureError=FailureCompressFailureError.fromString("setup_failed")
        @Assert(actCompressFailureError.getOrThrow().toString(),FailureCompressFailureError.setup_failed.toString())
        actCompressFailureError=FailureCompressFailureError.fromString("processing_failed")
        @Assert(actCompressFailureError.getOrThrow().toString(),FailureCompressFailureError.processing_failed.toString())
        actCompressFailureError=FailureCompressFailureError.fromString("unsupported_method")
        @Assert(actCompressFailureError.getOrThrow().toString(),FailureCompressFailureError.unsupported_method.toString())
        actCompressFailureError=FailureCompressFailureError.fromString("other")//问题确认中
        @Assert(actCompressFailureError.isNone(),true)
    }
    @TestCase
    func test_FailureCompressFailureError_operator_1_02(): Unit {
        var actCompressFailureError=FailureCompressFailureError.fromString("setup_failed")
        @Assert(actCompressFailureError==FailureCompressFailureError.setup_failed,true)
        @Assert(actCompressFailureError==FailureCompressFailureError.processing_failed,false)
        @Assert(actCompressFailureError==FailureCompressFailureError.unsupported_method,false)

        actCompressFailureError=FailureCompressFailureError.fromString("processing_failed")
        @Assert(actCompressFailureError==FailureCompressFailureError.setup_failed,false)
        @Assert(actCompressFailureError==FailureCompressFailureError.processing_failed,true)
        @Assert(actCompressFailureError==FailureCompressFailureError.unsupported_method,false)

        actCompressFailureError=FailureCompressFailureError.fromString("unsupported_method")
        @Assert(actCompressFailureError==FailureCompressFailureError.setup_failed,false)
        @Assert(actCompressFailureError==FailureCompressFailureError.processing_failed,false)
        @Assert(actCompressFailureError==FailureCompressFailureError.unsupported_method,true)
    }
}
