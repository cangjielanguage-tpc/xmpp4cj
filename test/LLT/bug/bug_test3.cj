// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjAbstractIqBuilder {
    @TestCase
    func test_StanzaBuilder01_createErrorResponse_01(): Unit {
        //public static func createErrorResponse (IqView request):IqData
        let request = UnparsedIQ("ele01", "namespace01", "elecontent01")
        let iqData = AbstractIqBuilder.createErrorResponse(request)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](iqData.build())
        @Assert("UnsupportedException", e.toString())
    }

    @TestCase
    func test_StanzaBuilder01_createResponse_01(): Unit {
        //public static func createResponse (IqView request):IqData
        let request = UnparsedIQ("ele01", "namespace01", "elecontent01")
        let iqData = AbstractIqBuilder.createResponse(request)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](iqData.build())
        @Assert("UnsupportedException", e.toString())
    }
}
