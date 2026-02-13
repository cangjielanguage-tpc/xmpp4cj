// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjAbstractIqBuilder{
    @TestCase
    func test_AbstractIqBuilder_createErrorResponse_01(): Unit {
        //public static func createErrorResponse (IqView request):IqData
        let request=UnparsedIQ("ele01","namespace01","elecontent01")
        let iqData=AbstractIqBuilder.createErrorResponse(request)
        let e:UnsupportedException=@AssertThrows[UnsupportedException](iqData.build())
        @Assert(e.toString(),"UnsupportedException")
    }
}